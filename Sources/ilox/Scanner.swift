//
//  Scanner.swift
//  Everything related to scanning source code.
//
//  Created by Victor Manuel Guerra Moran on 31/08/2021.
//

/// Scans lox source code.
class Scanner {
    let source: String
    var tokens: Array<Token>
    var start: Int = 0
    var current: Int = 0
    var nestedComments: Int = 0
    var line = 1

    static let keywords: [String: TokenType] = [
        "and": .AND,
        "class": .CLASS,
        "else": .ELSE,
        "false": .FALSE,
        "for": .FOR,
        "fun": .FUN,
        "if": .IF,
        "nil": .NIL,
        "or": .OR,
        "print": .PRINT,
        "return": .RETURN,
        "super": .SUPER,
        "this": .THIS,
        "true": .TRUE,
        "var": .VAR,
        "while": .WHILE
    ]

    internal init(source: String) {
        self.source = source
        self.tokens = Array<Token>()
    }
    
    var isAtEnd: Bool {
        current >= source.count
    }
    
    @discardableResult
    private func advance() -> Character {
        let currentChar = source[source.index(source.startIndex, offsetBy: current)]
        current = current + 1
        return currentChar
    }
    
    private func addTokenOf(type: TokenType) {
        addTokenOf(type: type, with: nil)
    }
    
    private func addTokenOf(type: TokenType, with literal: AnyObject?) {
        let code = source[start...(current - 1)]
        tokens.append(Token(type: type, lexeme: String(code), literal: literal, line: line))
    }
    
    private func match(expected char: Character) -> Bool {
        if (isAtEnd) {
            return false
        }
        if (source[current] != char) {
            return false
        }
        
        current = current + 1
        return true
    }
    
    private func peek() -> Character {
        if (isAtEnd) {
            return "\0";
        }
        return source[current]
    }
    
    private func peekNext() -> Character {
        if (current + 1 >= source.count) {
            return "\0"
        }
        return source[current + 1]
    }
    
    static private func isDigit(_ char: Character) -> Bool {
        return ("0"..."9").contains(char)
    }
    
    static private func isAlpha(_ char: Character) -> Bool {
        switch (char) {
        case "a"..."z", "A"..."Z", "_":
            return true
        default:
            return false
        }
    }
    
    static private func isAlphaNumeric(_ char: Character) -> Bool {
        return isDigit(char) || isAlpha(char)
    }

    private func consumeString() {
        while (peek() != "\"" && !isAtEnd) {
            if (peek() == "\n") {
                line = line + 1
            }
            advance()
        }
        
        if (isAtEnd) {
            ErrorUtil.error(line: line, message: "Unterminated string.")
            return
        }
        advance()
        
        let value = source[(start + 1)...(current - 2)]
        addTokenOf(type: .STRING, with: value as AnyObject)
    }
        
    private func consumeNumber() {
        while(Scanner.isDigit(peek())) {
            advance()
        }
        if (peek() == "." && Scanner.isDigit(peekNext())) {
            advance()
        }
        while(Scanner.isDigit(peek())) {
            advance()
        }
        addTokenOf(type: .NUMBER,
                   with: Double(String(source[start...current-1]))! as AnyObject)
    }
    
    private func consumeIdentifier() {
        while(Scanner.isAlphaNumeric(peek())) {
            advance()
        }
        let text = String(source[start...(current-1)])
        if let keywordType = Scanner.keywords[text] {
            addTokenOf(type: keywordType)
        } else {
            addTokenOf(type: .IDENTIFIER)
        }
    }
    
    private func scanToken() {
        let c = advance()
        switch (c) {
        // 1-2 character tokens
        case "(": addTokenOf(type: .LEFT_PAREN); break;
        case ")": addTokenOf(type: .RIGHT_PAREN); break;
        case "{": addTokenOf(type: .LEFT_BRACE); break;
        case "}": addTokenOf(type: .RIGHT_BRACE); break;
        case ",": addTokenOf(type: .COMMA); break;
        case ".": addTokenOf(type: .DOT); break;
        case "-": addTokenOf(type: .MINUS); break;
        case "+": addTokenOf(type: .PLUS); break;
        case ":": addTokenOf(type: .COLON); break;
        case ";": addTokenOf(type: .SEMICOLON); break;
        case "*": addTokenOf(type: .STAR); break;
        case "?": addTokenOf(type: .QUESTION_MARK); break;
        case "!": addTokenOf(type: match(expected: "=") ? .BANG_EQUAL : .BANG); break;
        case "=": addTokenOf(type: match(expected: "=") ? .EQUAL_EQUAL : .EQUAL); break;
        case "<": addTokenOf(type: match(expected: "=") ? .LESS_EQUAL : .LESS); break;
        case ">": addTokenOf(type: match(expected: "=") ? .GREATER_EQUAL : .GREATER); break;
        // Comments
        case "/":
            if (match(expected: "/")) {
                // We got a comment so we consume till the end of the line
                while (peek() != "\n" && !isAtEnd) {
                        advance()
                }
            } else if (match(expected: "*")) {
                nestedComments = 1
                while (nestedComments != 0 && !isAtEnd) {
                    if (peek() == "*") {
                        if (peekNext() == "/") {
                            advance()
                            nestedComments = nestedComments - 1
                        }
                    } else if (peek() == "/") {
                        if (peekNext() == "*") {
                            advance()
                            nestedComments = nestedComments + 1
                        }
                    } else if (peek() == "\n") {
                        line = line + 1
                    }
                    advance()
                }
                if (nestedComments != 0) {
                    ErrorUtil.error(line: line, message: "Unterminated comment(*/)")
                    break;
                }
            } else {
                addTokenOf(type: .SLASH)
            }
            break;
        // Spacing characters
        case " ", "\r", "\t":
            break;
        // New line
        case "\n":
            line = line + 1
            break;
        // Strings
        case "\"":
            consumeString()
            break;
        default:
            // Numerical constants
            if (Scanner.isDigit(c)) {
                consumeNumber()
            // Identifiers
            } else if (Scanner.isAlpha(c)) {
                consumeIdentifier()
            } else {
                ErrorUtil.error(line: line, message: "Unrecognized character: '\(c)'")
                break;
            }
        }
    }
    
    func scan() -> Array<Token> {
        while (!isAtEnd) {
            // We are at the beginning of the next lexeme.
            start = current
            scanToken();
        }
        
        tokens.append(Token(type: .EOF, lexeme: "", literal: nil, line: line))
        return tokens
    }
}
