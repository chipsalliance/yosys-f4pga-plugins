#include "kernel/sigtools.h"
#include "kernel/yosys.h"

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN

#define MODE_BITS_REGISTER_INPUTS_ID 92
#define MODE_BITS_OUTPUT_SELECT_START_ID 81
#define MODE_BITS_OUTPUT_SELECT_WIDTH 3

// ============================================================================

const std::vector<std::string> ports2del_mult = {"load_acc", "subtract", "acc_fir", "dly_b"};
const std::vector<std::string> ports2del_mult_acc = {"acc_fir", "dly_b"};
const std::vector<std::string> ports2del_mult_add = {"dly_b"};

void ql_dsp_io_regs_pass(RTLIL::Module *module)
{

    for (auto cell : module->cells_) {
        std::string cell_type = cell.second->type.str();
        if (cell_type == RTLIL::escape_id("QL_DSP2")) {
            auto dsp = cell.second;
            bool del_clk = false;

            // Get DSP configuration
            auto mode_bits = &dsp->getParam(RTLIL::escape_id("MODE_BITS"));
            RTLIL::Const register_inputs;
            register_inputs = mode_bits->bits.at(MODE_BITS_REGISTER_INPUTS_ID);
            int reg_in_i = register_inputs.as_int();

            RTLIL::Const output_select;
            output_select = mode_bits->extract(MODE_BITS_OUTPUT_SELECT_START_ID, MODE_BITS_OUTPUT_SELECT_WIDTH);
            int out_sel_i = output_select.as_int();

            // Build new type name
            std::string new_type = cell_type;
            new_type += "_MULT";

            switch (out_sel_i) {
            case 1:
                new_type += "ACC";
                break;
            case 2:
            case 3:
                new_type += "ADD";
                break;
            case 5:
                new_type += "ACC";
                break;
            case 6:
            case 7:
                new_type += "ADD";
                break;
            default:
                break;
            }

            if (reg_in_i)
                new_type += "_REGIN";

            if (out_sel_i > 3)
                new_type += "_REGOUT";

            // Set new type name
            dsp->type = RTLIL::IdString(new_type);

            // Delete ports unused in given type of DSP cell
            del_clk = (!reg_in_i && out_sel_i <= 3 && out_sel_i != 1);

            std::vector<std::string> ports2del;

            if (del_clk)
                ports2del.push_back("clk");

            switch (out_sel_i) {
            case 0:
            case 4:
                ports2del.insert(ports2del.end(), ports2del_mult.begin(), ports2del_mult.end());
                break;
            case 1:
            case 5:
                ports2del.insert(ports2del.end(), ports2del_mult_acc.begin(), ports2del_mult_acc.end());
                break;
            case 2:
            case 3:
            case 6:
            case 7:
                ports2del.insert(ports2del.end(), ports2del_mult_add.begin(), ports2del_mult_add.end());
                break;
            }

            for (auto portname : ports2del) {
                const RTLIL::SigSpec *port = &dsp->getPort(RTLIL::escape_id(portname));
                if (!port)
                    log_error("%s port not found!", portname.c_str());
                dsp->connections_.erase(RTLIL::escape_id(portname));
            }
        }
    }
}

struct QlDspIORegs : public Pass {

    QlDspIORegs() : Pass("ql_dsp_io_regs", "Does something") {}

    void help() override
    {
        log("\n");
        log("    ql_dsp_io_regs [options] [selection]\n");
        log("\n");
    }

    void execute(std::vector<std::string> a_Args, RTLIL::Design *a_Design) override
    {
        log_header(a_Design, "Executing QL_DSP_IO_REGS pass.\n");

        size_t argidx;
        for (argidx = 1; argidx < a_Args.size(); argidx++) {
            break;
        }
        extra_args(a_Args, argidx, a_Design);

        for (auto module : a_Design->selected_modules()) {
            ql_dsp_io_regs_pass(module);
        }
    }
} QlDspIORegs;

PRIVATE_NAMESPACE_END
