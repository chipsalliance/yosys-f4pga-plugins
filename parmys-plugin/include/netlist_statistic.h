#ifndef NETLIST_STATISTIC_HPP
#define NETLIST_STATISTIC_HPP

#include "netlist_utils.h"

static const unsigned int traversal_id = 0;
static const uintptr_t mult_optimization_traverse_value = (uintptr_t)&traversal_id;

stat_t *get_stats(nnode_t *node, netlist_t *netlist, uintptr_t traverse_mark_number);

void init_stat(netlist_t *netlist);
void compute_statistics(netlist_t *netlist, bool display);

/**
 * @brief This function will calculate and assign weights related
 * to mixing hard and soft logic implementation for certain kind
 * of logic blocks
 * @param node
 * The node that needs its weight to be assigned
 * @param netlist
 * netlist, has to be passed to the counting functions
 */
void mixing_optimization_stats(nnode_t *node, netlist_t *netlist);

#endif // NETLIST_STATISTIC_HPP
