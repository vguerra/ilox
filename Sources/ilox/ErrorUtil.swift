//
//  Error.swift
//  Error utilities
//
//  Created by Victor Manuel Guerra Moran on 31/08/2021.
//

import Foundation

enum LoxError : Error {
    case parse

    enum Runtime : Error {
        case operandNotNumber(token: Token)
        case operandsNotNumbers(token: Token)
        case operandsNotNumbersNorStrings(token: Token)
        case divisionByZero(token: Token)
        case undefinedVariable(token: Token)
    }

    case runtime(ofKind: Runtime)
}

extension LoxError.Runtime : LocalizedError {
    var errorDescription: String? {
        switch self {
            case .operandNotNumber(token: _):
                return "Operand must be a number."
            case .operandsNotNumbers(token: _):
                return "Operands must be numbers."
            case .operandsNotNumbersNorStrings(token: _):
                return "Operands must be either Numbers or Strings"
            case .divisionByZero(token: let tok):
                return "Division by zero at line: \(tok.line) "
            case .undefinedVariable(token: let tok):
                return "Undefined variable \(tok.lexeme) at line \(tok.line)."
        }
    }
}



enum ErrorUtil {
    static func error(line: Int, message: String) {
        report(line: line, within: "", message: message)
    }

    static func error(token: Token, message: String) {
        if (token.type == TokenType.EOF) {
            report(line: token.line, within: " at end", message: message)
        } else {
            report(line: token.line, within: "at '\(token.lexeme)'", message: message)
        }
    }

    static func report(message: String) {
        FileHandle.standardError.write(message.data(using: .utf8)!)
    }
    static func report(line: Int, within location: String, message: String) {
        report(message: "[line \(line)] Error \(location): \(message)\n")
    }

    static func runtimeError(rerror: LoxError) {
        if case LoxError.runtime(let kind) = rerror {
            let errorMsg = ("\(String(describing: kind.errorDescription!))\n".data(using: .utf8))!
            FileHandle.standardError.write(errorMsg)
        }
    }
}
