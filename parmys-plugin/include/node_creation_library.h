#ifndef NODE_CREATION_LIBRARY_H
#define NODE_CREATION_LIBRARY_H

#include "odin_types.h"

nnode_t *make_not_gate_with_input(npin_t *input_pin, nnode_t *node, short mark);

nnode_t *make_not_gate(nnode_t *node, short mark);
nnode_t *make_inverter(npin_t *pin, nnode_t *node, short mark);
nnode_t *make_1port_logic_gate(operation_list type, int width, nnode_t *node, short mark);

nnode_t *make_1port_gate(operation_list type, int width_input, int width_output, nnode_t *node, short mark);
nnode_t *make_2port_gate(operation_list type, int width_port1, int width_port2, int width_output, nnode_t *node, short mark);
nnode_t *make_3port_gate(operation_list type, int width_port1, int width_port2, int width_port3, int width_output, nnode_t *node, short mark);
nnode_t *make_nport_gate(operation_list type, int port_sizes, int width, int width_output, nnode_t *node, short mark);

char *node_name(nnode_t *node, char *instance_prefix_name);
char *op_node_name(operation_list op, char *instance_prefix_name);

const char *edge_type_blif_str(edge_type_e edge_type, loc_t loc);

extern nnode_t *make_multiport_smux(signal_list_t **inputs, signal_list_t *selector, int num_muxed_inputs, signal_list_t *outs, nnode_t *node,
                                    netlist_t *netlist);
#endif
