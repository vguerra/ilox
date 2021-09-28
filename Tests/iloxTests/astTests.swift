//
//  astTests.swift
//  
//
//  Created by Victor Guerra on 27/09/2021.
//

import XCTest
import FileCheck
@testable import ilox

final class astTests: XCTestCase {

    func testPrettyPrinter() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["PPRINT"], options: .disableColors) {
            let binaryExpr = Binary(
                left: Unary(op: Token(type: .MINUS, lexeme: "-", literal: nil, line: 1),
                            right: Literal(value: 123 as AnyObject)),
                op: Token(type: .STAR, lexeme: "*", literal: nil, line: 1),
                right: Grouping(expression: Literal(value: 45.67 as AnyObject)))

            // PPRINT: (* (- 123) (group 45.67))
            print(ASTPrinter().print(expr: binaryExpr))
        })
    }

    func testPrettyPrinterRPN() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["PPRINTRPN-1"], options: .disableColors) {
            let binaryExpr = Binary(
                left: Binary(left: Literal(value: 1 as AnyObject), op: Token(type: .PLUS, lexeme: "+", literal: nil, line: 1), right: Literal(value: 2 as AnyObject)),
                op: Token(type: .STAR, lexeme: "*", literal: nil, line: 1),
                right: Binary(left: Literal(value: 4 as AnyObject), op: Token(type: .MINUS, lexeme: "-", literal: nil, line: 1), right: Literal(value: 3 as AnyObject)))
            // PPRINTRPN-1: 1 2 + 4 3 - *
            print(ASTPrinterRPN().print(expr: binaryExpr))
        })

        XCTAssert(fileCheckOutput(withPrefixes: ["PPRINTRPN-2"], options: .disableColors) {
            let binaryExpr = Binary(
                left: Literal(value: 1 as AnyObject),
                op: Token(type: .STAR, lexeme: "*", literal: nil, line: 1),
                right: Unary(op: Token(type: .MINUS, lexeme: "-", literal: nil, line: 1), right: Literal(value: 3 as AnyObject)))
            // PPRINTRPN-2: 1 -3 *
            print(ASTPrinterRPN().print(expr: binaryExpr))
        })
    }

#if !os(macOS)
    static var allTests = testCase([
        ("testPrettyPrinter", testPrettyPrinter),
        ("testPrettyPrinterRPN", testPrettyPrinterRPN)
    ])
#endif
}
