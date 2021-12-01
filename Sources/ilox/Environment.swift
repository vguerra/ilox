//
//  Environment.swift
//  
//
//  Created by Victor Guerra on 25/11/2021.
//

final class Environment {
    var values: [String: AnyObject?] = [:]

    init() {}

    func get(_ name: Token) throws -> AnyObject? {
        if let value = values[name.lexeme] {
            return value
        }
        throw LoxError.runtime(ofKind: LoxError.Runtime.undefinedVariable(token: name))
    }

    func define(_ name: String, with value: AnyObject?) {
        values.updateValue(value, forKey: name)
    }
}
