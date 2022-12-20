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
#ifndef _PARMYS_UTILS_HPP_
#define _PARMYS_UTILS_HPP_

#include "odin_types.h"

Yosys::Wire *to_wire(std::string wire_name, Yosys::Module *module);
std::pair<Yosys::RTLIL::IdString, int> wideports_split(std::string name);
const std::string str(Yosys::RTLIL::SigBit sig);
const std::string str(Yosys::RTLIL::IdString id);
void handle_cell_wideports_cache(Yosys::hashlib::dict<Yosys::RTLIL::IdString, Yosys::hashlib::dict<int, Yosys::SigBit>> *cell_wideports_cache,
                                 Yosys::Design *design, Yosys::Module *module, Yosys::Cell *cell);
void handle_wideports_cache(Yosys::hashlib::dict<Yosys::RTLIL::IdString, std::pair<int, bool>> *wideports_cache, Yosys::Module *module);

#endif //_PARMYS_UTILS_HPP_