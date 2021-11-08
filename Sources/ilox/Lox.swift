//
//  Lox.swift
//  Lox interpreter
//
//  Created by Victor Manuel Guerra Moran on 07/09/2021.
//

import Darwin

struct CompilingPhases : OptionSet {
    let rawValue: Int

    static let scan = CompilingPhases(rawValue: 1 << 0)
    static let parse = CompilingPhases(rawValue: 1 << 1)
    static let interpret = CompilingPhases(rawValue: 1 << 2)
    static let allPhases = CompilingPhases(rawValue: 1 << 3)
}

struct Lox {
    private static var hadError: Bool = false
    private static var hadRuntimeError = false

    func runFile(from path:String, with phases: CompilingPhases) {
        if (Lox.hadError) {
            exit(65)
        }
        if (Lox.hadRuntimeError) {
            exit(70)
        }

    }

    func runPrompt() {
        print("Welcome to ilox interpreter, what can I run for you today?")
        while true {
            print("> ", terminator: "")
            let inputLine = readLine(strippingNewline: true)
            guard let line = inputLine else {
                print("\nBye!")
                break
            }
            run(code: line, with: .allPhases)
            Lox.hadError = false
        }
        
    }

    func run(code input: String, with phases: CompilingPhases) {
        let scanner = Scanner(source: input)
        let tokens = scanner.scan()

        if phases.contains(.scan) {
            for token in tokens {
                print(token)
            }
            return
        }

        let parser = Parser(tokens)
        let expression = parser.parse()

        if (Lox.hadError) {
            return
        }

        if phases.contains(.parse) {
            if let parsedExpr = expression {
                print(ASTPrinter().print(expr: parsedExpr))
                return
            }
        }

        if phases.contains(.interpret) || phases.contains(.allPhases) {
            if let parsedExpr = expression {
                let interpreter = Interpreter()
                interpreter.interpret(expression: parsedExpr)
            }
        }
    }
}
