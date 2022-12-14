/*
 * Copyright 2022 Daniel Khadivi
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
#include "parmys_utils.hpp"

Yosys::Wire *to_wire(std::string wire_name, Yosys::Module *module)
{
    Yosys::IdString wire_id = Yosys::RTLIL::escape_id(wire_name);
    Yosys::Wire *wire = module->wire(wire_id);

    if (wire == nullptr)
        wire = module->addWire(wire_id);

    return wire;
}

std::pair<Yosys::RTLIL::IdString, int> wideports_split(std::string name)
{
    int pos = -1;

    if (name.empty() || name.back() != ']')
        goto failed;

    for (int i = 0; i + 1 < Yosys::GetSize(name); i++) {
        if (name[i] == '[')
            pos = i;
        else if (name[i] != '-' && (name[i] < '0' || name[i] > '9'))
            pos = -1;
        else if (name[i] == '-' && ((i != pos + 1) || name[i + 1] == ']'))
            pos = -1;
        else if (i == pos + 2 && name[i] == '0' && name[i - 1] == '-')
            pos = -1;
        else if (i == pos + 1 && name[i] == '0' && name[i + 1] != ']')
            pos = -1;
    }

    if (pos >= 0)
        return std::pair<Yosys::RTLIL::IdString, int>("\\" + name.substr(0, pos), atoi(name.c_str() + pos + 1));

failed:
    return std::pair<Yosys::RTLIL::IdString, int>(Yosys::RTLIL::IdString(), 0);
}

const std::string str(Yosys::RTLIL::SigBit sig)
{
    // cstr_bits_seen.insert(sig);

    if (sig.wire == NULL) {
        if (sig == Yosys::RTLIL::State::S0)
            return "$false";
        if (sig == Yosys::RTLIL::State::S1)
            return "$true";
        return "$undef";
    }

    std::string str = Yosys::RTLIL::unescape_id(sig.wire->name);
    for (size_t i = 0; i < str.size(); i++)
        if (str[i] == '#' || str[i] == '=' || str[i] == '<' || str[i] == '>')
            str[i] = '?';

    if (sig.wire->width != 1)
        str +=
          Yosys::stringf("[%d]", sig.wire->upto ? sig.wire->start_offset + sig.wire->width - sig.offset - 1 : sig.wire->start_offset + sig.offset);

    return str;
}

const std::string str(Yosys::RTLIL::IdString id)
{
    std::string str = Yosys::RTLIL::unescape_id(id);
    for (size_t i = 0; i < str.size(); i++)
        if (str[i] == '#' || str[i] == '=' || str[i] == '<' || str[i] == '>')
            str[i] = '?';
    return str;
}

void handle_cell_wideports_cache(Yosys::hashlib::dict<Yosys::RTLIL::IdString, Yosys::hashlib::dict<int, Yosys::SigBit>> *cell_wideports_cache,
                                 Yosys::Design *design, Yosys::Module *module, Yosys::Cell *cell)
{
    Yosys::RTLIL::Module *cell_mod = design->module(cell->type);
    for (auto &it : *cell_wideports_cache) {
        int width = 0;
        int offset = 0;
        bool upto = false;
        for (auto &b : it.second)
            width = std::max(width, b.first + 1);

        if (cell_mod) {
            Yosys::Wire *cell_port = cell_mod->wire(it.first);
            if (cell_port && (cell_port->port_input || cell_port->port_output)) {
                offset = cell_port->start_offset;
                upto = cell_port->upto;
                width = cell_port->width;
            }
        }

        Yosys::SigSpec sig;

        for (int i = 0; i < width; i++) {
            int idx = offset + (upto ? width - 1 - i : i);
            if (it.second.count(idx))
                sig.append(it.second.at(idx));
            else
                sig.append(module->addWire(NEW_ID));
        }

        cell->setPort(it.first, sig);
    }
}

void handle_wideports_cache(Yosys::hashlib::dict<Yosys::RTLIL::IdString, std::pair<int, bool>> *wideports_cache, Yosys::Module *module)
{
    for (auto &wp : *wideports_cache) {
        auto name = wp.first;
        int width = wp.second.first;
        bool isinput = wp.second.second;

        Yosys::RTLIL::Wire *wire = module->addWire(name, width);
        wire->port_input = isinput;
        wire->port_output = !isinput;

        for (int i = 0; i < width; i++) {
            Yosys::RTLIL::IdString other_name = name.str() + Yosys::stringf("[%d]", i);
            Yosys::RTLIL::Wire *other_wire = module->wire(other_name);
            if (other_wire) {
                other_wire->port_input = false;
                other_wire->port_output = false;
                if (isinput)
                    module->connect(other_wire, Yosys::SigSpec(wire, i));
                else
                    module->connect(Yosys::SigSpec(wire, i), other_wire);
            }
        }
    }
}