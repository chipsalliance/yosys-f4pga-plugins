/*
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
#include <sstream>

#include "argparse.hpp"
#include "odin_ii.h"

#include "odin_globals.h"
#include "odin_types.h"

#include "HardSoftLogicMixer.hpp"
#include "vtr_path.h"

#define DEFAULT_OUTPUT "."

loc_t my_location;

t_arch Arch;
global_args_t global_args;
short physical_lut_size = -1;
HardSoftLogicMixer *mixer;

/* CONSTANT NET ELEMENTS */
char *one_string;
char *zero_string;
char *pad_string;

/*---------------------------------------------------------------------------
 * (function: set_default_options)
 *-------------------------------------------------------------------------*/
void set_default_config()
{
    /* Set up the global configuration. */
    configuration.coarsen = false;
    configuration.tcl_file = "";
    configuration.output_netlist_graphs = 0;
    // TODO: unused
    configuration.debug_output_path = std::string(DEFAULT_OUTPUT);
    configuration.dsp_verilog = "arch_dsp.v";
    configuration.arch_file = "";

    configuration.fixed_hard_multiplier = 0;
    configuration.split_hard_multiplier = 0;

    configuration.split_memory_width = 0;
    configuration.split_memory_depth = 0;

    configuration.adder_cin_global = false;

    /*
     * Soft logic cutoffs. If a memory or a memory resulting from a split
     * has a width AND depth below these, it will be converted to soft logic.
     */
    configuration.soft_logic_memory_width_threshold = 0;
    configuration.soft_logic_memory_depth_threshold = 0;
}
