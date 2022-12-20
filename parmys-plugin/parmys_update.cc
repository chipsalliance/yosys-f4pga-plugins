/*
 * Copyright 2022 CAS—Atlantic (University of New Brunswick, CASA)
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
#include <string.h>

#include "odin_globals.h"
#include "odin_types.h"

#include "vtr_memory.h"
#include "vtr_util.h"

#include "node_utils.h"

#include "adder.h"
#include "hard_block.h"
#include "multiplier.h"

#include "kernel/rtlil.h"
#include "parmys_update.hpp"
#include "parmys_utils.hpp"

static void depth_first_traversal_to_design(short marker_value, Yosys::Module *module, netlist_t *netlist, Yosys::Design *design);
static void depth_traverse_update_design(nnode_t *node, uintptr_t traverse_mark_number, Yosys::Module *module, netlist_t *netlist,
                                         Yosys::Design *design);
static void cell_node(nnode_t *node, short /*traverse_number*/, Yosys::Module *module, netlist_t *netlist, Yosys::Design *design);

Yosys::Wire *wire_net_driver(Yosys::Module *module, nnode_t *node, nnet_t *net, long driver_idx)
{
    oassert(driver_idx < net->num_driver_pins);
    npin_t *driver = net->driver_pins[driver_idx];
    std::string wire_name;
    if (!driver->node) {
        // Add a warning for an undriven net.
        warning_message(NETLIST, node->loc, "Net %s driving node %s is itself undriven.", net->name, node->name);

        wire_name = "$undef";
    } else {
        if (driver->name != NULL && ((driver->node->type == MULTIPLY) || (driver->node->type == HARD_IP) || (driver->node->type == MEMORY) ||
                                     (driver->node->type == ADD) || (driver->node->type == MINUS) || (driver->node->type == SKIP))) {
            wire_name = driver->name;
        } else {
            wire_name = driver->node->name;
        }
    }

    return to_wire(wire_name, module);
}

Yosys::Wire *wire_input_single_driver(Yosys::Module *module, nnode_t *node, long pin_idx)
{
    oassert(pin_idx < node->num_input_pins);
    nnet_t *net = node->input_pins[pin_idx]->net;
    if (!net->num_driver_pins) {
        return to_wire("$undef", module);
    } else {
        oassert(net->num_driver_pins == 1);
        return wire_net_driver(module, node, net, 0);
    }
}

Yosys::Wire *wire_output_pin(Yosys::Module *module, nnode_t *node)
{
    Yosys::RTLIL::IdString wire_name(Yosys::stringf("\\%s", node->name));
    Yosys::RTLIL::Wire *wire = module->wire(wire_name);
    if (wire == nullptr)
        wire = module->addWire(wire_name);

    return wire;
}

void update_design(Yosys::Design *design, netlist_t *netlist)
{
    Yosys::RTLIL::Module *module = nullptr;
    std::string err_reason;
    int blif_maxnum = 0;

    Yosys::hashlib::dict<Yosys::RTLIL::IdString, std::pair<int, bool>> wideports_cache;

    module = new Yosys::RTLIL::Module;
    module->name = Yosys::RTLIL::escape_id(strtok(netlist->identifier, " \t\r\n"));

    if (design->module(module->name))
        Yosys::log_error("Duplicate definition of module %s\n", Yosys::log_id(module->name));
    design->add(module);

    Yosys::RTLIL::SigSpec undef;
    undef.append(to_wire("$undef", module));
    module->connect(Yosys::RTLIL::SigSig(undef, Yosys::RTLIL::State::Sx));
    Yosys::RTLIL::SigSpec vcc;
    vcc.append(to_wire("$true", module));
    // vcc.append(module->wire(ID($true)));
    module->connect(Yosys::RTLIL::SigSig(vcc, Yosys::RTLIL::State::S1));
    Yosys::RTLIL::SigSpec gnd;
    gnd.append(to_wire("$false", module));
    module->connect(Yosys::RTLIL::SigSig(gnd, Yosys::RTLIL::State::S0));

    for (long i = 0; i < netlist->num_top_input_nodes; i++) {
        nnode_t *top_input_node = netlist->top_input_nodes[i];
        Yosys::RTLIL::Wire *wire = to_wire(top_input_node->name, module);
        wire->port_input = true;

        std::pair<Yosys::RTLIL::IdString, int> wp = wideports_split(top_input_node->name);
        if (!wp.first.empty() && wp.second >= 0) {
            wideports_cache[wp.first].first = std::max(wideports_cache[wp.first].first, wp.second + 1);
            wideports_cache[wp.first].second = true;
        }
    }

    for (long i = 0; i < netlist->num_top_output_nodes; i++) {
        nnode_t *top_output_node = netlist->top_output_nodes[i];
        if (!top_output_node->input_pins[0]->net->num_driver_pins) {
            Yosys::log_warning("This output is undriven (%s) and will be removed\n", top_output_node->name);
        } else {
            Yosys::RTLIL::Wire *wire = to_wire(top_output_node->name, module);
            wire->port_output = true;

            std::pair<Yosys::RTLIL::IdString, int> wp = wideports_split(top_output_node->name);
            if (!wp.first.empty() && wp.second >= 0) {
                wideports_cache[wp.first].first = std::max(wideports_cache[wp.first].first, wp.second + 1);
                wideports_cache[wp.first].second = false;
            }
        }
    }

    depth_first_traversal_to_design(100, module, netlist, design);

    /* connect all the outputs up to the last gate */
    for (long i = 0; i < netlist->num_top_output_nodes; i++) {
        nnode_t *node = netlist->top_output_nodes[i];

        if (node->input_pins[0]->net->num_fanout_pins > 0) {
            nnet_t *net = node->input_pins[0]->net;
            for (int j = 0; j < net->num_driver_pins; j++) {
                Yosys::Wire *driver_wire = wire_net_driver(module, node, net, j);
                Yosys::Wire *out_wire = to_wire(node->name, module);

                Yosys::RTLIL::SigSpec input_sig, output_sig;
                input_sig.append(driver_wire);
                output_sig.append(out_wire);

                module->connect(output_sig, input_sig);
            }
        }
    }

    handle_wideports_cache(&wideports_cache, module);

    module->fixup_ports();
    wideports_cache.clear();

    bool run_clean = true;
    if (run_clean) {
        Yosys::Const buffer_lut(std::vector<Yosys::RTLIL::State>({Yosys::State::S0, Yosys::State::S1}));
        std::vector<Yosys::Cell *> remove_cells;

        for (auto cell : module->cells())
            if (cell->type == ID($lut) && cell->getParam(Yosys::ID::LUT) == buffer_lut) {
                module->connect(cell->getPort(Yosys::ID::Y), cell->getPort(Yosys::ID::A));
                remove_cells.push_back(cell);
            }

        for (auto cell : remove_cells)
            module->remove(cell);

        Yosys::Wire *true_wire = module->wire(ID($true));
        Yosys::Wire *false_wire = module->wire(ID($false));
        Yosys::Wire *undef_wire = module->wire(ID($undef));

        if (true_wire != nullptr)
            module->rename(true_wire, Yosys::stringf("$true$%d", ++blif_maxnum));

        if (false_wire != nullptr)
            module->rename(false_wire, Yosys::stringf("$false$%d", ++blif_maxnum));

        if (undef_wire != nullptr)
            module->rename(undef_wire, Yosys::stringf("$undef$%d", ++blif_maxnum));

        blif_maxnum = 0;
    }

    add_the_blackbox_for_mults_yosys(design);
    add_the_blackbox_for_adds_yosys(design);

    output_hard_blocks_yosys(design);

    module = nullptr;
}

void depth_first_traversal_to_design(short marker_value, Yosys::Module *module, netlist_t *netlist, Yosys::Design *design)
{
    int i;

    if (!coarsen_cleanup) {
        netlist->gnd_node->name = vtr::strdup("$false");
        netlist->vcc_node->name = vtr::strdup("$true");
        netlist->pad_node->name = vtr::strdup("$undef");
    }

    depth_traverse_update_design(netlist->gnd_node, marker_value, module, netlist, design);
    depth_traverse_update_design(netlist->vcc_node, marker_value, module, netlist, design);
    depth_traverse_update_design(netlist->pad_node, marker_value, module, netlist, design);

    for (i = 0; i < netlist->num_top_input_nodes; i++) {
        if (netlist->top_input_nodes[i] != NULL) {
            depth_traverse_update_design(netlist->top_input_nodes[i], marker_value, module, netlist, design);
        }
    }
}

void depth_traverse_update_design(nnode_t *node, uintptr_t traverse_mark_number, Yosys::Module *module, netlist_t *netlist, Yosys::Design *design)
{
    int i, j;
    nnode_t *next_node;
    nnet_t *next_net;

    if (node->traverse_visited == traverse_mark_number) {
        return;
    } else {
        cell_node(node, traverse_mark_number, module, netlist, design);

        node->traverse_visited = traverse_mark_number;

        for (i = 0; i < node->num_output_pins; i++) {
            if (node->output_pins[i]->net == NULL)
                continue;

            next_net = node->output_pins[i]->net;
            for (j = 0; j < next_net->num_fanout_pins; j++) {
                if (next_net->fanout_pins[j] == NULL)
                    continue;

                next_node = next_net->fanout_pins[j]->node;
                if (next_node == NULL)
                    continue;

                depth_traverse_update_design(next_node, traverse_mark_number, module, netlist, design);
            }
        }
    }
}

void cell_node(nnode_t *node, short /*traverse_number*/, Yosys::Module *module, netlist_t *netlist, Yosys::Design *design)
{
    switch (node->type) {
    case GT:
        Yosys::log_error("GT\n");
        break;
    case LT:
        Yosys::log_error("LT\n");
        break;
    case BITWISE_NOT:
        Yosys::log_error("BITWISE_NOT\n");
        break;
    case BUF_NODE:
        Yosys::log_error("BUF_NODE\n");
        break;
    case LOGICAL_OR:
    case LOGICAL_AND:
    case LOGICAL_NOT:
    case LOGICAL_NOR:
    case LOGICAL_XOR:
    case ADDER_FUNC:
    case CARRY_FUNC:
    case LOGICAL_XNOR:
        define_logical_function_yosys(node, module);
        break;
    case LOGICAL_NAND:
    case LOGICAL_EQUAL:
    case NOT_EQUAL:
        Yosys::log_error("LOGICAL_\n");
        break;
    case MUX_2:
        define_MUX_function_yosys(node, module);
        break;

    case SMUX_2:
        define_SMUX_function_yosys(node, module);
        // Yosys::log_error("SMUX_2\n");
        break;

    case FF_NODE:
        define_FF_yosys(node, module);
        break;

    case MULTIPLY:
        oassert(hard_multipliers); /* should be soft logic! */
        define_mult_function_yosys(node, module, design);
        break;

    case ADD:
        oassert(hard_adders); /* should be soft logic! */
        define_add_function_yosys(node, module, design);
        break;

    case MINUS:
        oassert(hard_adders); /* should be soft logic! */
        define_add_function_yosys(node, module, design);
        break;

    case MEMORY:
    case HARD_IP:
        cell_hard_block(node, module, netlist, design);
        break;
    case CLOCK_NODE:
        Yosys::log_error("CLOCK\n");
        break;
    case INPUT_NODE:
    case OUTPUT_NODE:
    case PAD_NODE:
    case GND_NODE:
    case VCC_NODE:
        break;
    case SKIP:
        cell_hard_block(node, module, netlist, design);
        break;
    case BITWISE_AND:
    case BITWISE_NAND:
    case BITWISE_NOR:
    case BITWISE_XNOR:
    case BITWISE_XOR:
    case BITWISE_OR:
    case MULTI_PORT_MUX:
    case SL:
    case ASL:
    case SR:
    case ASR:
    case CASE_EQUAL:
    case CASE_NOT_EQUAL:
    case DIVIDE:
    case MODULO:
    case GTE:
    case LTE:
    default:
        Yosys::log_error("node should have been converted to softer version.");
        break;
    }
}

void define_FF_yosys(nnode_t *node, Yosys::Module *module)
{
    Yosys::Wire *d = wire_input_single_driver(module, node, 0);
    Yosys::Wire *q = wire_output_pin(module, node);
    const char *clk_edge_type_str = edge_type_blif_str(node->attributes->clk_edge_type, node->loc);
    char *edge = vtr::strdup(clk_edge_type_str);
    Yosys::Wire *clock = wire_input_single_driver(module, node, 1);

    if (clock == nullptr && edge != nullptr) {
        edge = nullptr;
    }

    if (node->initial_value == init_value_e::_0 || node->initial_value == init_value_e::_1)
        q->attributes[Yosys::ID::init] = Yosys::Const(node->initial_value, 1);

    if (clock == nullptr)
        goto no_latch_clock;

    if (!strcmp(edge, "re"))
        module->addDff(NEW_ID, clock, d, q);
    else if (!strcmp(edge, "fe"))
        module->addDff(NEW_ID, clock, d, q, false);
    else if (!strcmp(edge, "ah"))
        module->addDlatch(NEW_ID, clock, d, q);
    else if (!strcmp(edge, "al"))
        module->addDlatch(NEW_ID, clock, d, q, false);
    else {
    no_latch_clock:
        module->addFf(NEW_ID, d, q);
    }
}

void define_MUX_function_yosys(nnode_t *node, Yosys::Module *module)
{
    oassert(node->num_output_pins == 1);
    oassert(node->num_input_port_sizes == 2);
    oassert(node->input_port_sizes[0] == node->input_port_sizes[1]);

    Yosys::RTLIL::SigSpec input_sig_A, input_sig_B, buf_sig_M, output_sig;

    for (int i = 0; i < node->input_port_sizes[0]; i++) {
        nnet_t *input_net = node->input_pins[i]->net;
        Yosys::Wire *driver_wire = wire_net_driver(module, node, input_net, 0);

        input_sig_A.append(driver_wire);
    }

    for (int i = node->input_port_sizes[0]; i < node->num_input_pins; i++) {
        nnet_t *input_net = node->input_pins[i]->net;
        Yosys::Wire *driver_wire = wire_net_driver(module, node, input_net, 0);

        input_sig_B.append(driver_wire);
    }

    for (int i = 0; i < node->input_port_sizes[0]; i++) {
        std::string mid_buf_name = op_node_name(BUF_NODE, node->name);
        Yosys::RTLIL::Wire *buf_wire = to_wire(mid_buf_name, module);
        buf_sig_M.append(buf_wire);
    }

    Yosys::RTLIL::Wire *out_wire = to_wire(node->name, module);
    output_sig.append(out_wire);

    Yosys::IdString celltype_1 = ID($and);
    Yosys::RTLIL::Cell *cell_1 = module->addCell(NEW_ID, celltype_1);
    cell_1->setPort(Yosys::ID::A, input_sig_A);
    cell_1->parameters[Yosys::ID::A_WIDTH] = Yosys::RTLIL::Const(int(node->input_port_sizes[0]));
    cell_1->parameters[Yosys::ID::A_SIGNED] = Yosys::RTLIL::Const(false);
    cell_1->setPort(Yosys::ID::B, input_sig_B);
    cell_1->parameters[Yosys::ID::B_WIDTH] = Yosys::RTLIL::Const(int(node->input_port_sizes[1]));
    cell_1->parameters[Yosys::ID::B_SIGNED] = Yosys::RTLIL::Const(false);
    cell_1->setPort(Yosys::ID::Y, buf_sig_M);
    cell_1->parameters[Yosys::ID::Y_WIDTH] = Yosys::RTLIL::Const(int(node->input_port_sizes[0]));

    Yosys::IdString celltype_2 = ID($reduce_or);
    Yosys::RTLIL::Cell *cell_2 = module->addCell(NEW_ID, celltype_2);
    cell_2->setPort(Yosys::ID::A, buf_sig_M);
    cell_2->parameters[Yosys::ID::A_WIDTH] = Yosys::RTLIL::Const(int(node->input_port_sizes[0]));
    cell_2->parameters[Yosys::ID::A_SIGNED] = Yosys::RTLIL::Const(false);
    cell_2->setPort(Yosys::ID::Y, output_sig);
    cell_2->parameters[Yosys::ID::Y_WIDTH] = Yosys::RTLIL::Const(int(node->num_output_pins));
}

void define_logical_function_yosys(nnode_t *node, Yosys::Module *module)
{
    Yosys::RTLIL::SigSpec input_sig, output_sig;

    for (int i = 0; i < node->num_input_pins; i++) {
        nnet_t *input_net = node->input_pins[i]->net;
        Yosys::Wire *driver_wire = wire_net_driver(module, node, input_net, 0); // 0 TODO?

        input_sig.append(driver_wire);
    }

    Yosys::RTLIL::Wire *out_wire = to_wire(node->name, module);
    output_sig.append(out_wire);

    oassert(node->num_output_pins == 1);

    Yosys::IdString celltype;

    /* print out the blif definition of this gate */
    switch (node->type) {
    case LOGICAL_AND: {
        celltype = ID($reduce_and);
        break;
    }
    case LOGICAL_OR: {
        celltype = ID($reduce_or);
        break;
    }
    case LOGICAL_NAND: {
        /* generates: 0----- 1\n-0----- 1\n ... */
        break;
    }
    case LOGICAL_NOT:
    case LOGICAL_NOR: {
        celltype = ID($logic_not);
        break;
    }
    case LOGICAL_EQUAL:
        break;
    case ADDER_FUNC:
        oassert(node->num_input_pins == 3);
        celltype = ID($reduce_xor);
        break;
    case CARRY_FUNC:
        oassert(node->num_input_pins == 3);
        celltype = ID($lut);
        break;
    case LOGICAL_XOR: {
        oassert(node->num_input_pins <= 3);
        celltype = ID($reduce_xor);
        break;
    }
    case NOT_EQUAL:
    case LOGICAL_XNOR: {
        oassert(node->num_input_pins <= 3);
        celltype = ID($reduce_xnor);
        break;
    }
    default:
        oassert(false);
        break;
    }

    Yosys::RTLIL::Cell *cell = module->addCell(NEW_ID, celltype);

    cell->setPort(Yosys::ID::A, input_sig);
    cell->setPort(Yosys::ID::Y, output_sig);

    if (node->type == CARRY_FUNC) {
        cell->parameters[Yosys::ID::WIDTH] = Yosys::RTLIL::Const(input_sig.size());
        cell->parameters[Yosys::ID::LUT] = Yosys::RTLIL::Const(Yosys::RTLIL::State::Sx, 1 << input_sig.size());
        Yosys::RTLIL::Const *lutptr = NULL;
        lutptr = &cell->parameters.at(Yosys::ID::LUT);
        for (int i = 0; i < (1 << node->num_input_pins); i++) {
            if (i == 3 || i == 5 || i == 6 || i == 7) //"011 1\n101 1\n110 1\n111 1\n"
                lutptr->bits.at(i) = Yosys::RTLIL::State::S1;
            else
                lutptr->bits.at(i) = Yosys::RTLIL::State::S0;
        }
    } else {
        cell->parameters[Yosys::ID::A_WIDTH] = Yosys::RTLIL::Const(int(node->num_input_pins));
        cell->parameters[Yosys::ID::Y_WIDTH] = Yosys::RTLIL::Const(int(node->num_output_pins));
        cell->parameters[Yosys::ID::A_SIGNED] = Yosys::RTLIL::Const(false);
    }
}

void define_SMUX_function_yosys(nnode_t *node, Yosys::Module *module)
{
    Yosys::RTLIL::SigSpec input_sig_A, input_sig_B, input_sig_S, output_sig;

    oassert(node->num_input_pins == 3); // s a b

    nnet_t *s_net = node->input_pins[0]->net;
    Yosys::Wire *s_wire = wire_net_driver(module, node, s_net, 0);
    input_sig_S.append(s_wire);

    nnet_t *a_net = node->input_pins[1]->net;
    Yosys::Wire *a_wire = wire_net_driver(module, node, a_net, 0);
    input_sig_A.append(a_wire);

    nnet_t *b_net = node->input_pins[2]->net;
    Yosys::Wire *b_wire = wire_net_driver(module, node, b_net, 0);
    input_sig_B.append(b_wire);

    oassert(node->num_output_pins == 1); // y
    Yosys::RTLIL::Wire *out_wire = to_wire(node->name, module);
    output_sig.append(out_wire);

    Yosys::IdString celltype = ID($mux);
    ;

    Yosys::RTLIL::Cell *cell = module->addCell(NEW_ID, celltype);
    cell->parameters[Yosys::ID::WIDTH] = Yosys::RTLIL::Const(int(1));
    cell->setPort(Yosys::ID::S, input_sig_S);
    cell->setPort(Yosys::ID::A, input_sig_A);
    cell->setPort(Yosys::ID::B, input_sig_B);
    cell->setPort(Yosys::ID::Y, output_sig);
}