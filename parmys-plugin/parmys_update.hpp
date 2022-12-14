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
#ifndef __DESIGN_UPDATE_H__
#define __DESIGN_UPDATE_H__

#include "odin_types.h"

#define DEFAULT_CLOCK_NAME "GLOBAL_SIM_BASE_CLK"

void define_logical_function_yosys(nnode_t *node, Yosys::Module *module);
void update_design(Yosys::Design *design, netlist_t *netlist);
void define_MUX_function_yosys(nnode_t *node, Yosys::Module *module);
void define_SMUX_function_yosys(nnode_t *node, Yosys::Module *module);
void define_FF_yosys(nnode_t *node, Yosys::Module *module);

#endif //__DESIGN_UPDATE_H__