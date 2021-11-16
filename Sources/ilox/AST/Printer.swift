//
//  Printer.swift
//  An AST printer.
//
//  Created by Victor Guerra on 27/09/2021.
//

class ASTPrinter : ExprVisitor {
    typealias Return = String

    func print(expr: Expr) -> String {
        return expr.accept(visitor: self)
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
