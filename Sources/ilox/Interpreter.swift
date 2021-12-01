//
//  Interpreter.swift
//
//  Implements the logic to interpret each of the expression
//  nodes in an AST tree. The implementation is done using the
//  visitor pattern.
//
//  Created by Victor Guerra on 01/11/2021.
//

import Foundation


class Interpreter : ExprThrowableVisitor, StmtThrowableVisitor {

    typealias ExprReturn = AnyObject?
    typealias StmtReturn = Void

    private let environment = Environment()

    func interpret(statements : [Stmt]) {
        do {
            for statement in statements {
                try execute(statement: statement)
            }
        }  catch let error as LoxError {
            ErrorUtil.runtimeError(rerror: error)
        } catch {
            fatalError("Unexpected interpreter error.")
        }
    }

    private func execute(statement: Stmt) throws {
        try statement.accept(visitor: self)
    }

    private func stringify(value: AnyObject?) -> String {
        if let value = value {
            if (value is Double) {
                if (value.description.hasSuffix(".0")) {
                    let lastIndex = value.description.index(value.description.startIndex, offsetBy: value.description.count - 2)
                    return String(value.description[..<lastIndex])
                }
            }
            return value.description
        }

        return "nil"
    }

    func visitExprVariable(expr: Variable) throws -> AnyObject? {
        return try environment.get(expr.name)
    }

    func visitStmtVar(stmt: Var) throws -> Void {
        if let initializer = stmt.initializer {
            environment.define(stmt.name.lexeme, with: try evaluate(expr: initializer))
        } else {
            environment.define(stmt.name.lexeme, with: nil)
        }
    }

    func visitStmtExpression(stmt: Expression) throws -> Void {
        try evaluate(expr: stmt.expression)
    }

    func visitStmtPrint(stmt: Print) throws -> Void {
        let value = try evaluate(expr: stmt.expression)
        print(stringify(value: value))
    }

    func visitExprExprBlock(expr: ExprBlock) throws -> AnyObject? {
        fatalError("Not yet implemented")
    }

    func visitExprTernaryOp(expr: TernaryOp) throws -> AnyObject? {
        fatalError("Not yet implemented")
    }

    func visitExprBinary(expr: Binary) throws -> AnyObject? {
        let left = try evaluate(expr: expr.left)
        let right = try evaluate(expr: expr.right)

        switch expr.op.type {
            case .GREATER:
                try checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                return ((left as! Double) > (right as! Double)) as AnyObject
            case .GREATER_EQUAL:
                try checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                return ((left as! Double) >= (right as! Double)) as AnyObject
            case .LESS:
                try checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                return ((left as! Double) < (right as! Double)) as AnyObject
            case .LESS_EQUAL:
                try checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                return ((left as! Double) <= (right as! Double)) as AnyObject
            case .BANG_EQUAL:
                return !isEqual(left: left, right: right) as AnyObject
            case .EQUAL:
                return isEqual(left: left, right: right) as AnyObject
            case .MINUS:
                try checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                return (left as! Double) - (right as! Double) as AnyObject
            case .PLUS:
                if let unwrappedLeft = left, let unwrappedRight = right {
                    if unwrappedLeft is Double && unwrappedRight is Double {
                        return (unwrappedLeft as! Double) + (unwrappedRight as! Double) as AnyObject
                    } else if unwrappedLeft is String && unwrappedRight is String {
                        return (unwrappedLeft as! String) + (unwrappedRight as! String) as AnyObject
                    } else if unwrappedLeft is String {
                        return (unwrappedLeft as! String) + String(unwrappedRight as! Double) as AnyObject
                    } else if unwrappedRight is String {
                        return String(unwrappedLeft as! Double) + (unwrappedRight as! String) as AnyObject
                    }

                    throw LoxError.runtime(
                        ofKind: LoxError.Runtime.operandsNotNumbersNorStrings(token: expr.op)
                    )
                }
                return nil
            case .SLASH:
                try checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                let rightOp = right as! Double
                guard !rightOp.isZero else {
                    throw LoxError.runtime(
                        ofKind: LoxError.Runtime.divisionByZero(token: expr.op)
                    )
                }
                return (left as! Double) / rightOp as AnyObject
            case .STAR:
                try checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                return (left as! Double) * (right as! Double) as AnyObject
            default:
                return nil
        }
    }

    func visitExprGrouping(expr: Grouping) throws -> AnyObject? {
        return try evaluate(expr: expr.expression)
    }

    func visitExprLiteral(expr: Literal) throws -> AnyObject? {
        return expr.value
    }

    func visitExprUnary(expr: Unary) throws -> AnyObject? {
        let right = try evaluate(expr: expr.right)

        switch (expr.op.type) {
            case .MINUS:
                try checkNumberOperand(op: expr.op, operand: right)
                return -1 * Double(right! as! String)! as AnyObject
            case .BANG:
                return !isTruthty(object: right) as AnyObject
            default:
                return nil
        }
    }

    private func evaluate(expr: Expr) throws -> AnyObject? {
        return try expr.accept(visitor: self)
    }

    // We follow Ruby style: `false` and `nil` are falsey,
    // everything else is truthty.
    private func isTruthty(object: AnyObject?) -> Bool {
        if let wrappedObject = object {
            switch wrappedObject {
                case is Bool:
                    return wrappedObject as! Bool
                default:
                    return false
            }
        } else {
            return false
        }
    }

    private func isEqual(left: AnyObject?, right: AnyObject?) -> Bool {
        if left == nil && right == nil {
            return true
        } else if left == nil {
            return false
        }

        return left === right
    }

    private func checkNumberOperand(op: Token, operand: AnyObject?) throws {
        if let operand = operand {
            if operand is Double {
                return
            }
        }

        throw LoxError.runtime(ofKind: LoxError.Runtime.operandNotNumber(token: op))
    }

    private func checkNumberOperands(op: Token, leftOperand: AnyObject?, rightOperand: AnyObject?) throws {
        if let leftOperand = leftOperand, let rightOperand = rightOperand {
            if leftOperand is Double && rightOperand is Double {
                return
            }
        }

        throw LoxError.runtime(ofKind: LoxError.Runtime.operandsNotNumbers(token: op))
    }

}
