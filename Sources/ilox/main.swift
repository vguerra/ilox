import ArgumentParser
import Foundation

private struct LoxCommand : ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "ilox",
        abstract: "Lox programming language interpreter",
        discussion: """
            If you omit the source file option, you enter into REPL mode.
        """
    )

    @Option(name: [.customLong("source"), .customShort("s", allowingJoined: false)],
            help: ArgumentHelp("The path to the source file to execute."))
    var sourceFilePath : String = ""
    
    mutating func validate() throws {
        guard sourceFilePath.isEmpty || FileManager.default.fileExists(atPath: sourceFilePath) else {
            throw ValidationError("Source file path provided \(sourceFilePath) does not exists.")
        }
    }

    mutating func run() throws {
        let loxInterpreter = Lox()
        if !sourceFilePath.isEmpty {
            loxInterpreter.runFile(from: sourceFilePath)
        } else {
            loxInterpreter.runPrompt()
        }
        
    }
}

LoxCommand.main()
