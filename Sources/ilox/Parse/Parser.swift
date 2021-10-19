//
//  Parser.swift
//  
//
//  Created by Victor Guerra on 07/10/2021.
//

enum ParseError: Error {
    case parse
}

final class Parser {
    let tokens: [Token]
    var current: Int = 0

    init(_ tokens: [Token]) {
        self.tokens = tokens
    }

    func parse() -> Expr? {
        do {
            return try expressionBlock()
        } catch is ParseError {
            return nil;
        }
    }

    // MARK: Helper methods for tree navigation

    private func isAtEnd() -> Bool {
        return peek().type == .EOF
    }

    private func peek() -> Token {
        return tokens[current]
    }

    private func previous() -> Token {
        return tokens[current - 1]
    }

    private func match(_ types: TokenType...) -> Bool {
        for type in types {
            if (check(type)) {
                advance()
                return true
            }
        }

        return false
    }

    @discardableResult
    private func advance() -> Token {
        if (!isAtEnd()) {
            current = current + 1
        }
        return previous()
    }

    private func check(_ type: TokenType) -> Bool {
        if (isAtEnd()) {
            return false
        }
        return peek().type == type
    }

    // MARK: Parsing of grammar, each rule represented by one method.

    private func expressionBlock() -> Expr {
        var expr: Expr = expression()

        while (match(.COMMA)) {
            let tail = expressionBlock()
            expr = ExprBlock(head: expr, tail: tail)
        }

        return expr
    }

    private func expression() -> Expr {
        return equality();
    }

    private func equality() -> Expr {
        var expr: Expr = comparison();

        while (match(.BANG_EQUAL, .EQUAL_EQUAL)) {
            let op: Token = previous();
            let right: Expr = comparison();
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func comparison() -> Expr {
        var expr: Expr = term();

        while(match(.GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL)) {
            let op: Token = previous()
            let right: Expr = term();
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func term() -> Expr {
        var expr: Expr = factor();

        while(match(.MINUS, .PLUS)) {
            let op: Token = previous()
            let right: Expr = factor()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func factor() -> Expr {
        var expr: Expr = unary()

        while(match(.SLASH, .STAR)) {
            let op: Token = previous()
            let right: Expr = unary()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func unary() -> Expr {
        if (match(.BANG, .MINUS)) {
            let op: Token = previous()
            let right: Expr = unary()
            return Unary(op: op, right: right)
        }

        return try! primary()
    }

    private func primary() throws -> Expr {
        if (match(.FALSE)) {
            return Literal(value: false as AnyObject)
        }
        if (match(.TRUE)) {
            return Literal(value: true as AnyObject)
        }
        if (match(.NIL)) {
            return Literal(value: nil)
        }

        if (match(.NUMBER, .STRING)) {
            return Literal(value: previous().literal as AnyObject)
        }

        if (match(.LEFT_PAREN)) {
            let expr: Expr = expression()
            try! consume(TokenType.RIGHT_PAREN, "Expect ')' after expression")
            return Grouping(expression: expr)
        }

        throw error(peek(), "Expected expression.")
    }

    @discardableResult
    private func consume(_ type: TokenType, _ message: String) throws -> Token {
        if (check(type)) {
            return advance()
        }

        throw error(peek(), message)
    }

    private func error(_ token: Token, _ message: String) -> ParseError {
        ErrorUtil.error(token: token, message: message)
        return ParseError.parse
    }

    private func synchronize() {
        advance()

        while (!isAtEnd()) {
            if (previous().type == .SEMICOLON) {
                return
            }

            switch (peek().type) {
            case .CLASS,
                    .FUN,
                    .VAR,
                    .FOR,
                    .IF,
                    .WHILE,
                    .PRINT,
                    .RETURN:
                return
            default:
                advance()
            }
        }
    }
}
