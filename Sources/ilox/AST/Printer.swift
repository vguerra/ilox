//
//  Printer.swift
//  An AST printer.
//
//  Created by Victor Guerra on 27/09/2021.
//

class ASTPrinter : Visitor {
    typealias Return = String

    func print(expr: Expr) -> String {
        return expr.accept(visitor: self)
    }

    func visitExprBinary(expr: Binary) -> String {
        return parenthesize(name: expr.op.lexeme, expr.left, expr.right)
    }

    func visitExprGrouping(expr: Grouping) -> String {
        return parenthesize(name: "group", expr.expression)
    }

    func visitExprLiteral(expr: Literal) -> String {
        if (expr.value == nil) {
            return "nil"
        }
        return "\(expr.value)"
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