#ifndef AST_UTIL_H
#define AST_UTIL_H

#include "odin_types.h"

ast_node_t *create_node_w_type(ids id, loc_t loc);
ast_node_t *create_tree_node_id(char *string, loc_t loc);

#endif
