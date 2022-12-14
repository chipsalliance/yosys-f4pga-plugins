/*
 * Copyright (c) 2009 Peter Andrew Jamieson (jamieson.peter@gmail.com)
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
#include "odin_globals.h"
#include "odin_types.h"
#include <algorithm>
#include <ctype.h>
#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ast_util.h"
#include "odin_util.h"
#include "vtr_memory.h"
#include "vtr_util.h"

/*---------------------------------------------------------------------------
 * (function: create_node_w_type)
 *-------------------------------------------------------------------------*/
ast_node_t *create_node_w_type(ids id, loc_t loc)
{
    oassert(id != NO_ID);

    static long unique_count = 0;

    ast_node_t *new_node;

    new_node = (ast_node_t *)vtr::calloc(1, sizeof(ast_node_t));
    oassert(new_node != NULL);

    new_node->type = id;
    new_node->children = NULL;
    new_node->num_children = 0;
    new_node->unique_count = unique_count++; //++count_id;
    new_node->loc = loc;
    new_node->far_tag = 0;
    new_node->high_number = 0;
    new_node->hb_port = 0;
    new_node->net_node = 0;
    new_node->types.vnumber = nullptr;
    new_node->types.identifier = NULL;
    new_node->chunk_size = 1;
    new_node->identifier_node = NULL;
    /* init value */
    new_node->types.variable.initial_value = nullptr;
    /* reset flags */
    new_node->types.variable.is_parameter = false;
    new_node->types.variable.is_string = false;
    new_node->types.variable.is_localparam = false;
    new_node->types.variable.is_defparam = false;
    new_node->types.variable.is_port = false;
    new_node->types.variable.is_input = false;
    new_node->types.variable.is_output = false;
    new_node->types.variable.is_inout = false;
    new_node->types.variable.is_wire = false;
    new_node->types.variable.is_reg = false;
    new_node->types.variable.is_genvar = false;
    new_node->types.variable.is_memory = false;
    new_node->types.variable.signedness = UNSIGNED;

    new_node->types.concat.num_bit_strings = 0;
    new_node->types.concat.bit_strings = NULL;

    return new_node;
}

/*---------------------------------------------------------------------------------------------
 * (function: create_tree_node_id)
 *-------------------------------------------------------------------------------------------*/
ast_node_t *create_tree_node_id(char *string, loc_t loc)
{
    ast_node_t *new_node = create_node_w_type(IDENTIFIERS, loc);
    new_node->types.identifier = string;

    return new_node;
}
