//
//  Printer.swift
//  An AST printer.
//
//  Created by Victor Guerra on 27/09/2021.
//

class ASTPrinter : ExprVisitor, StmtVisitor {

    typealias ExprRetrun = String
    typealias StmtReturn = String

    func print(stmt: Stmt) -> String {
        return stmt.accept(visitor: self)
    }

    func print(expr: Expr) -> String {
        return expr.accept(visitor: self)
    }

    func visitExprVariable(expr: Variable) -> String {
        return  "var \(expr.name)"
    }

    func visitStmtVar(stmt: Var) -> String {
        if let initializerExpr = stmt.initializer {
            return parenthesize(name: "var \(stmt.name.lexeme) - init: ", initializerExpr)
        }
        return "(var \(stmt.name.lexeme) - init: null)"
    }

    func visitStmtExpression(stmt: Expression) -> String {
        return parenthesize(name: "stmt", stmt.expression)
    }

    func visitStmtPrint(stmt: Print) -> String {
        return parenthesize(name: "print", stmt.expression)
    }

    func visitExprExprBlock(expr: ExprBlock) -> String {
        return parenthesize(name: "expr-block", expr.head, expr.tail)
    }

    func visitExprTernaryOp(expr: TernaryOp) -> String {
        return parenthesize(
            name: "ternary",
            expr.condition,
            expr.thenExpr,
            expr.elseExpr)
    }

    func visitExprBinary(expr: Binary) -> String {
        return parenthesize(name: expr.op.lexeme, expr.left, expr.right)
    }

    func visitExprGrouping(expr: Grouping) -> String {
        return parenthesize(name: "group", expr.expression)
    }

    func visitExprLiteral(expr: Literal) -> String {
        if let val = expr.value {
            return "\(val)"
        }
        return "nil"
    }

    func visitExprUnary(expr: Unary) -> String {
        return parenthesize(name: expr.op.lexeme, expr.right)
    }

    private func parenthesize(name: String, _ exprs: Expr...) -> String {
        var expandedStr = "(\(name)"
        for expr in exprs {
            expandedStr += " \(expr.accept(visitor: self))"
        }
        expandedStr += ")"
        return expandedStr
    }
}
