/*
 *  yosys -- Yosys Open SYnthesis Suite
 *
 *  Copyright (C) 2012  Clifford Wolf <clifford@clifford.at>
 *  Copyright (C) 2019  The Symbiflow Authors
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *  ---
 *
 *   FASM backend
 *
 *   This plugin writes out the design's fasm features based on the parameter
 *   annotations on the design cells.
 */

#include "../common/bank_tiles.h"
#include "kernel/celltypes.h"
#include "kernel/log.h"
#include "kernel/register.h"
#include "kernel/rtlil.h"
#include "kernel/sigtools.h"

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN

struct SplitportsPass : public ScriptPass {
    SplitportsPass() : ScriptPass("splitports", "split up multi-bit nets and") {}

    void help() override
    {
        //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
        log("\n");
        log("    splitports [options] [selection]\n");
        log("\n");
        log("This command splits multi-bit nets and ports into single-bit entities.\n");
        log("\n");
        log("    -format char1[char2[char3]]\n");
        log("        the first char is inserted between the net name and the bit index, the\n");
        log("        second char is appended to the netname. e.g. -format () creates net\n");
        log("        names like 'mysignal(42)'. the 3rd character is the range separation\n");
        log("        character when creating multi-bit wires. the default is '[]:'.\n");
        log("\n");
        log("    -ports\n");
        log("        also split module ports. per default only internal signals are split.\n");
        log("\n");
        log("    -driver\n");
        log("        don't blindly split nets in individual bits. instead look at the driver\n");
        log("        and split nets so that no driver drives only part of a net.\n");
        log("\n");
    }

    void execute(std::vector<std::string> args, RTLIL::Design *design) override
    {
        string run_from, run_to;

        log_header(design, "Executing SPLITPORTS internal script pass.\n");
        log_push();

        run_script(design, run_from, run_to);

        log_pop();

        log_header(design, "Executing SPLITPORTS pass (splitting up multi-bit signals).\n");
        std::map<IdString, std::map<IdString, std::map<IdString, std::map<IdString, std::map<IdString, std::map<int, RTLIL::SigSpec>>>>>> new_ports;
        std::map<IdString, std::map<IdString, int>> processed;
        std::map<IdString, std::map<IdString, std::map<IdString, int>>> old_wires;
        //       mod->name          cell->type	    wire->name  wire->width

        // split ports in cell definitions
        for (auto module : design->selected_modules()) {
            IdString module_id = module->name;

            pool<RTLIL::Wire *> split_wires;
            for (auto cell : module->cells()) {
                if (cell->type.c_str()[0] == '$')
                    continue;

                auto mod = design->module(cell->type);

                if (mod && !processed[mod->name][cell->type])
                    processed[mod->name][cell->type] = 1; // Mark as processed
                else
                    continue; // No module for given cell type found or module already processed

                // process wires of unprocessed module
                for (auto wire : mod->wires()) {
                    int width = wire->width;
                    if ((wire->port_input || wire->port_output) && width > 1) {

                        split_wires.insert(wire); // prepare list of wires to split and replace
                    }
                    old_wires[mod->name][cell->type][wire->name] = width;
                }
                for (auto wire : split_wires) {
                    int width = wire->width;

                    // Create new wires outside mod->wires() iteration because it is not a valid action
                    for (int offset = 0; offset < width; offset++) {
                        RTLIL::Wire *new_wire = mod->addWire(mod->uniquify(wire->name.c_str() + stringf("_%d", offset)), 1);
                        new_wire->port_id = wire->port_id ? wire->port_id + offset : 0; // <- ids overlap !
                        new_wire->port_input = wire->port_input;
                        new_wire->port_output = wire->port_output;
                        new_wire->start_offset = 0;

                        auto it = wire->attributes.find(ID::src);
                        if (it != wire->attributes.end())
                            new_wire->attributes.emplace(ID::src, it->second);

                        it = wire->attributes.find(ID::hdlname);
                        if (it != wire->attributes.end())
                            new_wire->attributes.emplace(ID::hdlname, it->second);

                        it = wire->attributes.find(ID::keep);
                        if (it != wire->attributes.end())
                            new_wire->attributes.emplace(ID::keep, it->second);

                        it = wire->attributes.find(ID::init);
                        if (it != wire->attributes.end()) {
                            Const old_init = it->second, new_init;
                            for (int i = offset; i < offset + width; i++)
                                new_init.bits.push_back(i < GetSize(old_init) ? old_init.bits.at(i) : State::Sx);
                            new_wire->attributes.emplace(ID::init, new_init);
                        }
                    }
                }
                mod->remove(split_wires); // remove old multi bit wires
                mod->fixup_ports();       // fix ports numbering

                split_wires.clear();
            }
            for (auto cell : module->cells()) {
                // Skip internal cells
                // TODO: Is there a better way to check if a cell is internal ?
                if (cell->type.c_str()[0] == '$')
                    continue;

                for (auto connection : cell->connections()) {
                    int width = connection.second.size();

                    if (width == 0) {
                        auto m = design->module(cell->type);
                        if (m) {
                            int oldwire_width = old_wires[m->name][cell->type][connection.first];

                            if (oldwire_width > 1) {
                                for (int i = 0; i < oldwire_width; i++) {
                                    char *newwire_name_str;
                                    asprintf(&newwire_name_str, "%s_%d", connection.first.c_str(), i);
                                    auto w = m->wire(newwire_name_str);
                                    if (w) {
                                        IdString split_wirename = IdString(newwire_name_str);
                                        RTLIL::SigSpec split_sig = SigSpec(w);
                                        new_ports[module_id][cell->type][connection.first][split_wirename][w->name][w->width] = split_sig;
                                    }
                                }
                            } else {
                                auto w = m->wire(connection.first.c_str());
                                if (w) {
                                    IdString split_wirename = connection.first;
                                    RTLIL::SigSpec split_sig = SigSpec(w);
                                    new_ports[module_id][cell->type][connection.first][split_wirename][w->name][w->width] = split_sig;
                                }
                            }
                        }
                    } else if (width > 1) {
                        int sp_id = 0;
                        for (auto chunk : connection.second.chunks()) { // each chunk is 1bit wide
                            if (chunk.wire) {
                                char *split_portname_str;
                                asprintf(&split_portname_str, "%s_%d", connection.first.c_str(), sp_id);
                                IdString split_portname = IdString(split_portname_str);

                                RTLIL::SigSpec split_sig = SigSpec(chunk.wire); // new 1bit wide sigspec used for creating 1bit ports
                                new_ports[module_id][cell->type][connection.first][split_portname][chunk.wire->name][chunk.wire->width] = split_sig;
                            }
                            ++sp_id;
                        }
                    }
                }
            }
            if (!new_ports.count(module_id))
                continue;
            auto cell_map = new_ports[module_id];

            for (auto cell : module->cells()) {
                IdString cell_id = cell->type;

                if (!cell_map.count(cell_id))
                    continue;
                auto conn_map = new_ports[module_id][cell_id];

                for (auto conn : cell->connections()) {
                    IdString port_id = conn.first;

                    if (!conn_map.count(port_id)) {
                        continue;
                    }

                    auto new_port_map = new_ports[module_id][cell_id][port_id];
                    // prefetch width because it will be the same for all wires in inner loop
                    int wire_width = new_port_map.begin()->second.begin()->second.begin()->first;
                    // process only ports that have already single wires
                    if (wire_width > 1)
                        continue;

                    for (auto new_port : new_port_map) {
                        IdString new_port_id = new_port.first;

                        if (!new_port_map.count(new_port_id))
                            continue;
                        IdString wire_id = new_port.second.begin()->first;
                        RTLIL::SigSpec new_sig = new_port.second.begin()->second.begin()->second;

                        cell->setPort(new_port_id, new_sig);
                    }
                    if (!cell->hasPort(port_id))
                        continue;

                    cell->unsetPort(port_id);
                }
            }
        }
    }

    void script() override { run("splitnets -ports -driver -format ()"); }

} SplitportsPass;

PRIVATE_NAMESPACE_END
