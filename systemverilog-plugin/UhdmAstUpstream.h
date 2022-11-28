#ifndef YOSYS_SYSTEMVERILOG_PLUGIN_UHDM_AST_UPSTREAM_H_
#define YOSYS_SYSTEMVERILOG_PLUGIN_UHDM_AST_UPSTREAM_H_

#include <algorithm>
#include <string>
#include <vector>

#include "frontends/ast/ast.h"

YOSYS_NAMESPACE_BEGIN

namespace AST
{
enum AstNodeTypeExtended {
    AST_DOT = AST::AST_BIND + 1, // here we always want to point to the last element of yosys' AstNodeType
    AST_BREAK,
    AST_CONTINUE
};
}

AST::AstNode *mkconst_real(double d);

namespace VERILOG_FRONTEND
{

// convert the Verilog code for a constant to an AST node
AST::AstNode *const2ast(std::string code, char case_type, bool warn_z);

} // namespace VERILOG_FRONTEND

YOSYS_NAMESPACE_END

#endif // YOSYS_SYSTEMVERILOG_PLUGIN_UHDM_AST_UPSTREAM_H_
