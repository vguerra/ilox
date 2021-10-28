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
            return try expression()
        } catch {
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

    // MARK: Parsing of grammar, each rule represented by one method
    private func expression() throws -> Expr {
        return try expressionBlock()
    }

    private func expressionBlock() throws -> Expr {
        var expr: Expr = try conditional()

        while (match(.COMMA)) {
            let tail = try  expressionBlock()
            expr = ExprBlock(head: expr, tail: tail)
        }

        return expr
    }

    private func conditional() throws -> Expr {
        let expr = try equality();

        // TODO: handle errors for ternary op syntax.
        if (match(.QUESTION_MARK)) {
            let thenExpr = try expression()
            if (match(.COLON)) {
                let elseExpr = try conditional()
                return TernaryOp(condition: expr, thenExpr: thenExpr, elseExpr: elseExpr)
            }
        }

        return expr;
    }

    private func equality() throws -> Expr {
        var expr: Expr = try comparison();

        while (match(.BANG_EQUAL, .EQUAL_EQUAL)) {
            let op: Token = previous();
            let right: Expr = try comparison();
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func comparison() throws -> Expr {
        var expr: Expr = try term();

        while(match(.GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL)) {
            let op: Token = previous()
            let right: Expr = try term();
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func term() throws -> Expr {
        var expr: Expr = try factor();

        while(match(.MINUS, .PLUS)) {
            let op: Token = previous()
            let right: Expr = try factor()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func factor() throws -> Expr {
        var expr: Expr = try unary()

        while(match(.SLASH, .STAR)) {
            let op: Token = previous()
            let right: Expr = try unary()
            expr = Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func unary() throws -> Expr {
        if (match(.BANG, .MINUS)) {
            let op: Token = previous()
            let right: Expr = try unary()
            return Unary(op: op, right: right)
        }

        return try primary()
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
            let expr: Expr = try expression()
            try! consume(TokenType.RIGHT_PAREN, "Expect ')' after expression")
            return Grouping(expression: expr)
        }

        // MARK: Handling Error productions

        if (match(.BANG_EQUAL, .EQUAL_EQUAL)) {
            let leftOpError = error(previous(), "Missing left hand term for operator.")
            let _ = try comparison()
            throw leftOpError
        }

        if (match(.GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL)) {
            let leftOpError = error(previous(), "Missing left hand term for operator.")
            let _ = try term()
            throw leftOpError
        }

        if (match(.MINUS, .PLUS)) {
            let leftOpError = error(previous(), "Missing left hand term for operator.")
            let _ = try factor()
            throw leftOpError
        }

        if (match(.SLASH, .STAR)) {
            let leftOpError = error(previous(), "Missing left hand term for operator.")
            let _ = try unary()
            throw leftOpError
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
