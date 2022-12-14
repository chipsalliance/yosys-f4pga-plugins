#ifndef ODIN_UTIL_H
#define ODIN_UTIL_H

#include <string>

#include "odin_types.h"

long shift_left_value_with_overflow_check(long input_value, long shift_by, loc_t loc);

const char *name_based_on_op(operation_list op);
const char *node_name_based_on_op(nnode_t *node);

char *make_full_ref_name(const char *previous, const char *module_name, const char *module_instance_name, const char *signal_name, long bit);

std::string make_simple_name(char *input, const char *flatten_string, char flatten_char);

void *my_malloc_struct(long bytes_to_alloc);

char *append_string(const char *string, const char *appendage, ...);

double wall_time();

int odin_sprintf(char *s, const char *format, ...);

void passed_verify_i_o_availabilty(nnode_t *node, int expected_input_size, int expected_output_size, const char *current_src, int line_src);

#endif
