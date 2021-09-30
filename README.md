# ilox

Interpreter for the Lox programming language.

This implementatin is based on the [Crafting interpreters](http://craftinginterpreters.com/) book and it's code snippets.
## Supported syntax

This implementation supports the following:

### Grammar

* Literals
* Unary expressions: Negation of expressions and numbers
* Binary expressions: Infix arithmetic operations and logical operators
* Grouping of expressions via parentheses

```
expression -> literal 
            | unary 
            | binary 
            | grouping ; 
literal    -> NUMBER | STRING | "true" | "false" | "nil" ; 
grouping   -> "(" expression ")" ; 
unary      -> ( "-" | "!" ) expression ; 
binary     -> expression operator expression ; 
operator   -> "==" | "!=" | "<" | "<=" | ">" | ">=" | "+" | "-" | "*" | "/" ; 
```
