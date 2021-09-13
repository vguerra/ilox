//
//  Error.swift
//  Error utilities
//
//  Created by Victor Manuel Guerra Moran on 31/08/2021.
//

import Foundation

enum Error {
    static func error(line: Int, message:String) {
        report(line: line, within: "", message: message)
    }

    static func report(line: Int, within location: String, message: String) {
        FileHandle.standardError.write("[line \(line)] Error \(location): \(message)\n".data(using: .utf8)!)
    }
}
