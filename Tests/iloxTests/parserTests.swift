//
//  parserTests.swift
//  
//
//  Created by Victor Guerra on 15/10/2021.
//

import XCTest
import FileCheck
@testable import ilox

final class basicTest: XCTestCase {
    let loxInterpreter = Lox()

    func testPrettyPrinter() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["PARSER"], options: .disableColors) {
            // PARSER: (+ 3 1)
            loxInterpreter.run(code: "3 + 1", with: .parse)
        })
}

#if !os(macOS)
    static var allTests = testCase([
        ("basicTest", basicTest)
    ])
#endif
}
