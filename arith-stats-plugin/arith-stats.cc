#include <stdlib.h>

#include <algorithm>
#include <string>

#include "kernel/celltypes.h"
#include "kernel/log.h"
#include "kernel/register.h"
#include "kernel/rtlil.h"
#include "kernel/sigtools.h"
#include "kernel/yosys.h"

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN

struct ArithStats : public Pass {
  ArithStats()
      : Pass("arith_stats",
             "Print out information about arithmetic operators in design.") {}

  void help() override {
    //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
    log("\n");
    log("    arith_stats\n");
    log("\n");
    log("Print out information about arithmetic operators in design.\n");
    log("\n");
  }

  void execute(std::vector<std::string> args, RTLIL::Design *design) override {
    (void)args;  // no args / not used
    log("Executing 'arith_stats' command.");
    for (const RTLIL::Module *module : design->selected_modules()) {
      std::map<RTLIL::IdString, std::map<int, int>> histos_by_type;
      std::map<RTLIL::IdString, int> tot_counts;

      // === COLLECT data for this module
      for (const RTLIL::Cell *cell : module->selected_cells()) {
        if (!cell->type.in(ID($add), ID($sub), ID($neg), ID($alu), ID($fa),
                           ID($macc), ID($mul), ID($div), ID($lt), ID($le),
                           ID($gt), ID($ge))) {
          continue;
        }

        // Get the width of the arith cell
        int width = 0;
        if (cell->type.in(ID($fa))) {
          width = std::max(width, cell->parameters.at(ID::WIDTH).as_int());
        } else {
          width = std::max(width, cell->parameters.at(ID::A_WIDTH).as_int());
          if (!cell->type.in(ID($neg))) {
            width = std::max(width, cell->parameters.at(ID::B_WIDTH).as_int());
          }
          width = std::max(width, cell->parameters.at(ID::Y_WIDTH).as_int());
        }

        // update total counts by type
        const auto typ = cell->type;
        tot_counts[typ] = (tot_counts.count(typ) ? tot_counts[typ] : 0) + 1;

        // update width historgram
        auto &histo = histos_by_type[typ];
        histo[width] = (histo.count(width) ? histo[width] : 0) + 1;
      }

      // === DISPLAY info for this module
      if (!histos_by_type.empty()) {
        log("\nCounting arithmetic cells in module %s:\n",
            module->name.c_str());
      }
      for (const auto &[typ, histo] : histos_by_type) {
        log("\n%s: total %d instances\n", typ.c_str(), tot_counts[typ]);
        log("    %10s : %-10s\n", "bitwidth", "count");
        for (const auto &[width, count] : histo) {
          log("    %10d : %-10d\n", width, count);
        }
      }
    }
  }
};

static struct ArithStats *instance = new struct ArithStats();

PRIVATE_NAMESPACE_END
