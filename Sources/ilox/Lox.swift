//
//  Lox.swift
//  Lox interpreter
//
//  Created by Victor Manuel Guerra Moran on 07/09/2021.
//

import Darwin

struct Lox {
    private static var hadError: Bool = false
    
    func runFile(from path:String) {
    
        if (Lox.hadError) {
            exit(65)
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
            run(code: line)
            Lox.hadError = false
        }
        
    }
    
    func run(code input: String) {
        let scanner = Scanner(source: input)
        let tokens = scanner.scan()
        
        for token in tokens {
            print(token)
        }
    }
}
