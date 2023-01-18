// Copyright 2022 AUC Open Source Hardware Lab
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

#include "kernel/yosys.h"

USING_YOSYS_NAMESPACE
#include <iostream>
struct CLK_Gating_Pass : public Pass {

    CLK_Gating_Pass() : Pass("reg_clock_gating", "performs flipflop clock gating") {}

    void help() override
    {
        //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
        log("\n");
        log("     reg_clock_gating [-map CG_map_filename] [selection]\n");
        log("\n");
        log("\n");
        log("    -map filename\n");
        log("        the mapfile for clock gating cells implementations to be used.\n");
        log("        maps from enable-flipflops to clock gated flipflops.\n");
        log("        without this parameter a builtin library is used that\n");
        log("        transforms the internal RTL cells to the internal gate\n");
        log("        library.\n");
        log("        check techmap command for mare details.\n");
        log("     selection\n");
        log("        this option is used to specify the flipflops to be clockgated.\n");
        log("        for example:.\n");
        log("        put the following attribute in you design: \n");
        log("        (* clock gating *).\n");
        log("        and use the following command: .\n");
        log("        reg_clock_gating -map CG_map_filename.v a:clock_gate.\n");
        log("\n");
        log("This pass calls the following passes to perform technology mapping \n");
        log("of enabled flip_flops to clock-gated flipflops.\n");
        log("\n");
        log("    procs\n");
        log("    opt;;\n");
        log("    memory_collect\n");
        log("    memory_map\n");
        log("    opt;; \n");
        log("    techmap -map [-map CG_map_filename] [selection]\n");
        log("    opt;;\n");
        log("\n");
    }

    virtual void execute(std::vector<std::string> args, RTLIL::Design *design)
    {

        if (args.size() < 2) {
            log_error("Incorrect number of arguments \nClock gating map file is required \n");
        }

        string map_file = "";

        size_t argidx;
        for (argidx = 1; argidx < args.size(); argidx++) {
            if (args[argidx] == "-map" && argidx + 1 < args.size()) {
                map_file = args[++argidx];
                continue;
            }
            break;
        }
        int x = 0;
        std::stringstream selection_string_stream;
        for (unsigned long i = argidx; i < args.size(); i++) {
            if (x != 0)
                selection_string_stream << " ";
            selection_string_stream << args[i];
            x++;
        }
        std::string selection = selection_string_stream.str();

        std::cout << selection << "\n";

        log_header(design, "Executing Clock gating pass.\n");
        log_push();

        Pass::call(design, "proc");
        Pass::call(design, "opt;;");
        Pass::call(design, "memory_collect " + selection);
        Pass::call(design, "memory_map " + selection);
        Pass::call(design, "opt;;");
        Pass::call(design, "techmap -map " + map_file + " " + selection);
        Pass::call(design, "opt;;");

        design->optimize();
        design->sort();
        design->check();

        log_header(design, "Finished Clock gating pass.\n");
        log_pop();
    }
} CLK_Gating_Pass;
