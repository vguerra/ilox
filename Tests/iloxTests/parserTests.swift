//
//  parserTests.swift
//  
//
//  Created by Victor Guerra on 15/10/2021.
//

import XCTest
import FileCheck
@testable import ilox

final class parserTests: XCTestCase {
    let loxInterpreter = Lox()

    func testPrettyPrinter() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["PPRINT"], options: .disableColors) {
            // PPRINT: (+ 3 1)
            loxInterpreter.run(code: "3 + 1;", with: .parse)
        })
    }

    func testExprBlock() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["EXPR_BLOCK"], options: .disableColors) {
            // EXPR_BLOCK: (expr-block (+ 3 1) (expr-block (< 2 3) (! 1)))
            loxInterpreter.run(code: "3 + 1, 2 < 3, !true;", with: .parse)
        })
    }

    func testTernaryOperator() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["TERNARY_OP"], options: .disableColors) {
            // TERNARY_OP: (ternary (> 2 3) 1 2)
            loxInterpreter.run(code: "2 > 3 ? 1 : 2;", with: .parse)
            // TERNARY_OP: (ternary (> 2 3) 1 (ternary (< 1 2) 10 12))
            loxInterpreter.run(code: "2 > 3 ? 1 : 1 < 2 ? 10 : 12;", with: .parse)
            // TERNARY_OP: (ternary (> 2 3) (ternary (< 1 2) 10 12) 1)
            loxInterpreter.run(code: "2 > 3 ? 1 < 2 ? 10 : 12 : 1;", with: .parse)
        })
    }

    func testErrorMissingLeftOperandBinaryOps() throws {
        XCTAssert(fileCheckOutput(of: .stderr, withPrefixes: ["LEFTOP_ERROR"], options: .disableColors) {
            // LEFTOP_ERROR: Error at '>': Missing left hand term for operator.
            loxInterpreter.run(code: "> 3;", with: .parse)
            // LEFTOP_ERROR: Error at '*': Missing left hand term for operator.
            loxInterpreter.run(code: "* 1;", with: .parse)
        })
    }

#if !os(macOS)
    static var allTests = testCase([
        ("testPrettyPrinter", testPrettyPrinter),
        ("testExprBlock", testExprBlock),
        ("testTernaryOperator", testTernaryOperator),
        ("testErrorMissingLeftOperandBinaryOps", testErrorMissingLeftOperandBinaryOps)
    ])
#endif
}
