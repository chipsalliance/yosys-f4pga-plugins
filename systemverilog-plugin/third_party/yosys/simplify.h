#include "frontends/ast/ast.h"

namespace systemverilog_plugin
{
    bool simplify(Yosys::AST::AstNode *ast_node, bool const_fold, bool at_zero, bool in_lvalue, int stage, int width_hint, bool sign_hint, bool in_param);
}
