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

#include "UhdmAst.h"
#include "frontends/ast/ast.h"
#include "kernel/yosys.h"
#include "uhdmcommonfrontend.h"

#if defined(_MSC_VER)
#include <direct.h>
#include <process.h>
#else
#include <sys/param.h>
#include <unistd.h>
#endif
#include <memory>

#include "Surelog/ErrorReporting/Report.h"
#include "Surelog/surelog.h"

namespace UHDM
{
extern void visit_object(vpiHandle obj_h, int indent, const char *relation, std::set<const BaseClass *> *visited, std::ostream &out,
                         bool shallowVisit = false);
}

YOSYS_NAMESPACE_BEGIN

// SURELOG::scompiler wrapper.
// Owns UHDM/VPI resources used by designs returned from `execute`
class Compiler
{
  public:
    Compiler() = default;
    ~Compiler()
    {
        if (this->scompiler) {
            SURELOG::shutdown_compiler(this->scompiler);
        }
    }

    const std::vector<vpiHandle> &execute(std::unique_ptr<SURELOG::ErrorContainer> errors, std::unique_ptr<SURELOG::CommandLineParser> clp)
    {
        log_assert(!this->errors && !this->clp && !this->scompiler);

        bool success = true;
        bool noFatalErrors = true;
        unsigned int codedReturn = 0;
        clp->setWriteUhdm(false);
        errors->printMessages(clp->muteStdout());
        if (success && (!clp->help())) {
            this->scompiler = SURELOG::start_compiler(clp.get());
            if (!this->scompiler)
                codedReturn |= 1;
            this->designs.push_back(SURELOG::get_uhdm_design(this->scompiler));
        }
        SURELOG::ErrorContainer::Stats stats;
        if (!clp->help()) {
            stats = errors->getErrorStats();
            if (stats.nbFatal)
                codedReturn |= 1;
            if (stats.nbSyntax)
                codedReturn |= 2;
        }
        bool noFErrors = true;
        if (!clp->help())
            noFErrors = errors->printStats(stats, clp->muteStdout());
        if (noFErrors == false) {
            noFatalErrors = false;
        }
        if ((!noFatalErrors) || (!success) || (errors->getErrorStats().nbError))
            codedReturn |= 1;
        if (codedReturn) {
            log_error("Error when parsing design. Aborting!\n");
        }

        this->clp = std::move(clp);
        this->errors = std::move(errors);

        return this->designs;
    }

  private:
    std::unique_ptr<SURELOG::ErrorContainer> errors = nullptr;
    std::unique_ptr<SURELOG::CommandLineParser> clp = nullptr;
    SURELOG::scompiler *scompiler = nullptr;
    std::vector<vpiHandle> designs = {};
};

struct UhdmSurelogAstFrontend : public UhdmCommonFrontend {
    UhdmSurelogAstFrontend(std::string name, std::string short_help) : UhdmCommonFrontend(name, short_help) {}
    UhdmSurelogAstFrontend() : UhdmCommonFrontend("verilog_with_uhdm", "generate/read UHDM file") {}
    void help() override
    {
        //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
        log("\n");
        log("    read_verilog_with_uhdm [options] [filenames]\n");
        log("\n");
        log("Read SystemVerilog files using Surelog into the current design\n");
        log("\n");
        this->print_read_options();
    }
    AST::AstNode *parse(std::string filename) override
    {
        std::vector<const char *> cstrings;
        cstrings.reserve(this->args.size());
        for (size_t i = 0; i < this->args.size(); ++i)
            cstrings.push_back(const_cast<char *>(this->args[i].c_str()));

        auto symbolTable = std::make_unique<SURELOG::SymbolTable>();
        auto errors = std::make_unique<SURELOG::ErrorContainer>(symbolTable.get());
        auto clp = std::make_unique<SURELOG::CommandLineParser>(errors.get(), symbolTable.get(), false, false);
        bool success = clp->parseCommandLine(cstrings.size(), &cstrings[0]);
        if (!success) {
            log_error("Error parsing Surelog arguments!\n");
        }
        // Force -parse flag settings even if it wasn't specified
        clp->setwritePpOutput(true);
        clp->setParse(true);
        clp->fullSVMode(true);
        clp->setCacheAllowed(true);
        if (this->shared.defer) {
            clp->setCompile(false);
            clp->setElaborate(false);
            clp->setSepComp(true);
        } else {
            clp->setCompile(true);
            clp->setElaborate(true);
        }
        if (this->shared.link) {
            clp->setLink(true);
        }

        Compiler compiler;
        const auto &uhdm_designs = compiler.execute(std::move(errors), std::move(clp));

        if (this->shared.debug_flag || !this->report_directory.empty()) {
            for (auto design : uhdm_designs) {
                std::stringstream strstr;
                UHDM::visit_object(design, 1, "", &this->shared.report.unhandled, this->shared.debug_flag ? std::cout : strstr);
            }
        }

        // on parse_only mode, don't try to load design
        // into yosys
        if (this->shared.parse_only)
            return nullptr;

        if (this->shared.defer && !this->shared.link)
            return nullptr;

        // FIXME: SynthSubset annotation is incompatible with separate compilation
        // `-defer` turns elaboration off, so check for it
        // Should be called 1. for normal flow 2. after finishing with `-link`
        if (!this->shared.defer) {
            UHDM::Serializer serializer;
            UHDM::SynthSubset *synthSubset =
              make_new_object_with_optional_extra_true_arg<UHDM::SynthSubset>(&serializer, this->shared.nonSynthesizableObjects, false);
            synthSubset->listenDesigns(uhdm_designs);
            delete synthSubset;
        }

        UhdmAst uhdm_ast(this->shared);
        AST::AstNode *current_ast = uhdm_ast.visit_designs(uhdm_designs);
        if (!this->report_directory.empty()) {
            this->shared.report.write(this->report_directory);
        }

        return current_ast;
    }
    void call_log_header(RTLIL::Design *design) override { log_header(design, "Executing Verilog with UHDM frontend.\n"); }
} UhdmSurelogAstFrontend;

struct UhdmSystemVerilogFrontend : public UhdmSurelogAstFrontend {
    UhdmSystemVerilogFrontend() : UhdmSurelogAstFrontend("systemverilog", "read SystemVerilog files") {}
    void help() override
    {
        //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
        log("\n");
        log("    read_systemverilog [options] [filenames]\n");
        log("\n");
        log("Read SystemVerilog files using Surelog into the current design\n");
        log("\n");
        this->print_read_options();
    }
} UhdmSystemVerilogFrontend;

YOSYS_NAMESPACE_END
