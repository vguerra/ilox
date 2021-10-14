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
    var sourceFilePath: String = ""

    @Flag(help: "Emit the tokens produced by the scanner.")
    var emitTokens:  Bool = false

    mutating func validate() throws {
        guard sourceFilePath.isEmpty || FileManager.default.fileExists(atPath: sourceFilePath) else {
            throw ValidationError("Source file path provided \(sourceFilePath) does not exists.")
        }
    }

    mutating func run() throws {
        var compilingPhases: CompilingPhases = []
        if (emitTokens) {
            compilingPhases.update(with: .scan)
        } else {
            compilingPhases.update(with: .allPhases)
        }
        let loxInterpreter = Lox()
        if !sourceFilePath.isEmpty {
            loxInterpreter.runFile(from: sourceFilePath, with: compilingPhases)
        } else {
            loxInterpreter.runPrompt()
        }
        
    }
}

LoxCommand.main()
