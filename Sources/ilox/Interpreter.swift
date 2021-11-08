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


class Interpreter : Visitor {

    enum RuntimeError : Error {
        case OperandNotNumber(token: Token)
        case OperandsNotNumbers(token: Token)
        case OperandsNotNumbersNorStrings(token: Token)
    }

    typealias Return = AnyObject?

    func interpret(expression: Expr) {
        print(stringify(value: evaluate(expr: expression)))
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

    func visitExprExprBlock(expr: ExprBlock) -> AnyObject? {
        fatalError("Not yet implemented")
    }

    func visitExprTernaryOp(expr: TernaryOp) -> AnyObject? {
        fatalError("Not yet implemented")
    }

    func visitExprBinary(expr: Binary) -> AnyObject? {
        let left = evaluate(expr: expr.left)
        let right = evaluate(expr: expr.right)

        switch expr.op.type {
            case .GREATER:
                try! checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                return ((left as! Double) > (right as! Double)) as AnyObject
            case .GREATER_EQUAL:
                try! checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                return ((left as! Double) >= (right as! Double)) as AnyObject
            case .LESS:
                try! checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                return ((left as! Double) < (right as! Double)) as AnyObject
            case .LESS_EQUAL:
                try! checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                return ((left as! Double) <= (right as! Double)) as AnyObject
            case .BANG_EQUAL:
                return !isEqual(left: left, right: right) as AnyObject
            case .EQUAL:
                return isEqual(left: left, right: right) as AnyObject
            case .MINUS:
                try! checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                return (left as! Double) - (right as! Double) as AnyObject
            case .PLUS:
                if let unwrappedLeft = left, let unwrappedRight = right {
                    if unwrappedLeft is Double && unwrappedRight is Double {
                        return (unwrappedLeft as! Double) + (unwrappedRight as! Double) as AnyObject
                    }
                    if unwrappedLeft is String && unwrappedRight is String {
                        return (unwrappedLeft as! String) + (unwrappedRight as! String) as AnyObject
                    }

                    try! throwPlusOperandsError(token: expr.op)
                }
                return nil
            case .SLASH:
                try! checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                return (left as! Double) / Double(right as! Double) as AnyObject
            case .STAR:
                try! checkNumberOperands(op: expr.op, leftOperand: left, rightOperand: right)
                return (left as! Double) * Double(right as! Double) as AnyObject
            default:
                return nil
        }
    }

    func visitExprGrouping(expr: Grouping) -> AnyObject? {
        return evaluate(expr: expr.expression)
    }

    func visitExprLiteral(expr: Literal) -> AnyObject? {
        return expr.value
    }

    func visitExprUnary(expr: Unary) -> AnyObject? {
        let right = evaluate(expr: expr.right)

        switch (expr.op.type) {
            case .MINUS:
                try! checkNumberOperand(op: expr.op, operand: right)
                return -1 * Double(right! as! String)! as AnyObject
            case .BANG:
                return !isTruthty(object: right) as AnyObject
            default:
                return nil
        }
    }

    private func evaluate(expr: Expr) -> AnyObject? {
        return expr.accept(visitor: self)
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

        throw RuntimeError.OperandNotNumber(token: op)
    }

    private func checkNumberOperands(op: Token, leftOperand: AnyObject?, rightOperand: AnyObject?) throws {
        if let leftOperand = leftOperand, let rightOperand = rightOperand {
            if leftOperand is Double && rightOperand is Double {
                return
            }
        }

        throw RuntimeError.OperandsNotNumbers(token: op)
    }

    private func throwPlusOperandsError(token: Token) throws {
        throw RuntimeError.OperandsNotNumbersNorStrings(token: token)
    }

}

extension Interpreter.RuntimeError : LocalizedError {
    var errorDescription: String? {
        switch self {
            case .OperandNotNumber(token: _):
                return "Operand must be a number."
            case .OperandsNotNumbers(token: _):
                return "Operands must be numbers."
            case .OperandsNotNumbersNorStrings(token: _):
                return "Operands must be either Numbers or Strings"
        }
    }
}
