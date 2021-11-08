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

    func numericExpressions() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["NUM"], options: .disableColors) {
            // NUM: 5
            loxInterpreter.run(code: "3 + 2", with: .interpret)
            // NUM: 1
            loxInterpreter.run(code: "3 - 2", with: .interpret)
            // NUM: 6
            loxInterpreter.run(code: "3 * 2", with: .interpret)
            // NUM: 2
            loxInterpreter.run(code: "4 / 2", with: .interpret)
        })
    }

    func stringExpressions() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["STR"], options: .disableColors) {
            // STR: abcd
            loxInterpreter.run(code: "\"ab\" + \"cd\"", with: .interpret)
        })
    }


#if !os(macOS)
    static var allTests = testCase([
        ("numericExpressions", numericExpressions),
        ("stringExpressions", stringExpressions)
    ])
#endif
}
