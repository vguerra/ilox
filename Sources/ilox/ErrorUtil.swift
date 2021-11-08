//
//  Error.swift
//  Error utilities
//
//  Created by Victor Manuel Guerra Moran on 31/08/2021.
//

import Foundation

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

    static func report(line: Int, within location: String, message: String) {
        FileHandle.standardError.write("[line \(line)] Error \(location): \(message)\n".data(using: .utf8)!)
    }

    static func runtimeError(rerror: Interpreter.RuntimeError) {
        FileHandle.standardError.write((rerror.errorDescription?.data(using: .utf8))!)
    }
}
