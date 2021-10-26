//
//  PrinterRPN.swift
//  An AST printer with reverse polish notation for Binary and Unary ops.
//
//  Created by Victor Guerra on 27/09/2021.
//

class ASTPrinterRPN : Visitor {
    typealias Return = String

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

    func print(expr: Expr) -> String {
        return expr.accept(visitor: self)
    }

    func visitExprBinary(expr: Binary) -> String {
        return toRPN(name: expr.op.lexeme, left: expr.left, right: expr.right)
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
        return "\(expr.op.lexeme)\(expr.right.accept(visitor: self))"
    }

    private func parenthesize(name: String, _ exprs: Expr...) -> String {
        var expandedStr = "(\(name)"
        for expr in exprs {
            expandedStr += " \(expr.accept(visitor: self))"
        }
        expandedStr += ")"
        return expandedStr
    }

    private func toRPN(name: String, left: Expr, right: Expr) -> String {
        return "\(left.accept(visitor: self)) \(right.accept(visitor: self)) \(name)"
    }
}
