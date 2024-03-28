/*
 * Copyright 2020-2022 F4PGA Authors
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
 *
 */
#include "kernel/log.h"
#include <fstream>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

USING_YOSYS_NAMESPACE
// Coordinates of HCLK_IOI tiles associated with a specified bank
using BankTilesMap = std::unordered_map<int, std::string>;

// Find the part's JSON file with information including the IO Banks
// and extract the bank tiles.
inline BankTilesMap get_bank_tiles(const std::string json_file_name)
{
    BankTilesMap bank_tiles;
    std::ifstream json_file(json_file_name);
    if (!json_file.good()) {
        log_cmd_error("Can't open JSON file %s", json_file_name.c_str());
    }

    json data;
    try {
        data = json::parse(json_file);
    } catch (json::parse_error &ex) {
        log_cmd_error("json parsing error: %s\n", ex.what());
        return bank_tiles;
    }

    auto iobanks = data.find("iobanks");
    if (iobanks == data.end()) {
        log_cmd_error("IO Bank information missing in the part's json: %s\n", json_file_name.c_str());
    }

    for (auto &el : iobanks->items()) {
        bank_tiles.emplace(std::atoi(el.key().c_str()), to_string(el.value()));
    }

    return bank_tiles;
}
