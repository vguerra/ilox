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

#if !os(macOS)
    static var allTests = testCase([
        ("testPrettyPrinter", testPrettyPrinter)
    ])
#endif
}
