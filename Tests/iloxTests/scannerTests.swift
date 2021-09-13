import XCTest
import FileCheck
@testable import ilox

final class iloxTests: XCTestCase {
    let loxInterpreter = Lox()

    func testScanning1CharTokens() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["1CTOKENS"], options: .disableColors) {
            // 1CTOKENS: EQUAL = nil
            // 1CTOKENS-NEXT: EOF  nil
            loxInterpreter.run(code: "=")
        })
    }
    
    func testScanning2CharTokens() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["2CTOKENS"], options: .disableColors) {
            // 2CTOKENS-NOT: EQUAL = nil
            // 2CTOKENS: EQUAL_EQUAL == nil
            // 2CTOKENS-NEXT: EOF  nil
            loxInterpreter.run(code: "==")
        })
    }
    
    func testScanningComments() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["COMM_TOKENS"], options: .disableColors) {
            // COMM_TOKENS: EQUAL_EQUAL == nil
            // COMM_TOKENS-NEXT: EOF  nil
            let code = """
            // This is a comment <= ==
            // var != < this as well
            ==
            """
            loxInterpreter.run(code: code)
        })
    }
    
    func testScanningStrings() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["STR_TOKENS"], options: .disableColors) {
            // STR_TOKENS: STRING("Ta Tb") "Ta Tb" nil
            // STR_TOKENS-NEXT: EOF  nil
            loxInterpreter.run(code: "\"Ta Tb\"")
        })
    }
    
    func testScanningNumbers() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["NUM_TOKENS"], options: .disableColors) {
            // NUM_TOKENS: NUMBER(3.14) 3.14 nil
            // NUM_TOKENS-NEXT: EOF  nil
            loxInterpreter.run(code: "3.14")
        })
    }
    
    func testScanningKeywords() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["KEYWORD_TOKENS"]) {
            // KEYWORD_TOKENS: CLASS class nil
            // KEYWORD_TOKENS-NEXT: FOR for nil
            // KEYWORD_TOKENS-NEXT: WHILE while nil
            // KEYWORD_TOKENS-NEXT: EOF  nil
            loxInterpreter.run(code: "class for while")
        })
    }
    
    func testScanningIdentifiers() throws {
        XCTAssert(fileCheckOutput(withPrefixes: ["IDENTIFIER_TOKENS"]) {
            // IDENTIFIER_TOKENS: IDENTIFIER("thisIsAnIdentifier") thisIsAnIdentifier nil
            // IDENTIFIER_TOKENS-NEXT: EOF  nil
            loxInterpreter.run(code: "thisIsAnIdentifier")
        })
    }

    #if !os(macOS)
    static var allTests = testCase([
        ("testScanning1CharTokens", testScanning1CharTokens),
        ("testScanning2CharTokens", testScanning2CharTokens),
        ("testScanningComments", testScanningComments),
        ("testScanningStrings", testScanningStrings),
        ("testScanningNumbers", testScanningNumbers),
        ("testScanningKeywords", testScanningKeywords),
        ("testScanningIdentifiers", testScanningIdentifiers)
    ])
    #endif
}
