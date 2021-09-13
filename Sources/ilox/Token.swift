//
//  Token.swift
//  Definition of Token supported by Lox.
//
//  Created by Victor Manuel Guerra Moran on 31/08/2021.
//

/// Tokens that are accepted by the language.
enum TokenType {
    // Single-character tokens.
    case LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE, COMMA,
    DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR
    
    // One or two character tokens.
    case BANG, BANG_EQUAL, EQUAL, EQUAL_EQUAL, GREATER, GREATER_EQUAL, LESS, LESS_EQUAL
    
    // Literals
    case IDENTIFIER(String), STRING(String), NUMBER(Double)
    
    // Keywords
    case AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR, PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE, EOF
}


/// Represents a Token
struct Token : CustomStringConvertible {
    let type: TokenType
    let lexeme: String
    let literal: AnyObject?
    let line: Int
    
    var description: String {
        "\(self.type) \(self.lexeme) \(String(describing: self.literal))"
    }

    internal init(type: TokenType, lexeme: String, literal: AnyObject?, line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
    }
}
