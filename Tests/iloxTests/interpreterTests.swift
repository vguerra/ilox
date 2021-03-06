//
//  interpreterTests.swift
//
//
//  Created by Victor Guerra on 08/11/2021.
//

import XCTest
import FileCheck
@testable import ilox

final class interpreterTests: XCTestCase {
    let loxInterpreter = Lox()

    func testNumericExpressions() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["NUM"], options: .disableColors) {
            // NUM: 5
            loxInterpreter.run(code: "print 3 + 2;", with: .interpret)
            // NUM: 1
            loxInterpreter.run(code: "print 3 - 2;", with: .interpret)
            // NUM: 6
            loxInterpreter.run(code: "print 3 * 2;", with: .interpret)
            // NUM: 2
            loxInterpreter.run(code: "print 4 / 2;", with: .interpret)
        })
    }

    func testStringExpressions() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["STR"], options: .disableColors) {
            // STR: abcd
            loxInterpreter.run(code: "print \"ab\" + \"cd\";", with: .interpret)
        })
    }

    func testAddStringAndNumbers() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["STR_NUM"], options: .disableColors) {
            // STR_NUM: 23.3ab
            loxInterpreter.run(code: "print 23.3 + \"ab\";", with: .interpret)
            // STR_NUM: ab23.3
            loxInterpreter.run(code: "print \"ab\" + 23.3;", with: .interpret)
        })
    }

    func testDivisionByZero() throws {
        XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["DIV_ZERO"], options: .disableColors) {
            // DIV_ZERO: Division by zero at line: 1
            loxInterpreter.run(code: "3 / 0;", with: .interpret)
        })
    }

    func testVariables() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["VARS"], options: .disableColors) {
            // VARS: 3
            loxInterpreter.run(
                code: """
                var a = 1;
                var b = 2;
                print a + b;
            """, with: .interpret)
        })
    }


#if !os(macOS)
    static var allTests = testCase([
        ("testNumericExpressions", numericExpressions),
        ("testStringExpressions", stringExpressions),
        ("testAddStringAndNumbers", addStringAndNumbers),
        ("testDivisionByZero", testDivisionByZero),
        ("testVariables", testVariables)
    ])
#endif
}
