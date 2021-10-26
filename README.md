# ilox

[![Build Status](https://github.com/vguerra/ilox/actions/workflows/ci.yml/badge.svg)](https://github.com/vguerra/ilox/actions/workflows/ci.yml)

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
; Grammar for Lox.

expression  = equality

equality    = comparison *( ( "!=" / "==" ) comparison )

comparison  = term *( ( ">" / ">=" / "<" / "<=" ) term )

term        = factor *( ( "-" / "+" ) factor )

factor      = unary *( ( "/" / "*" ) unary )

unary       = ( "-" / "!" ) unary / primary

primary     = 1*DIGIT "." 1*DIGIT / 1*ALPHA /
              "true" / "false" / "nil" / "(" expression ")"
```

Find the definition in the [lox.abnf](grammar/lox.abnf) file. 

A graphical representation.

<img src="grammar/lox.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px; background-color: white" />

#### Operator Associativity

To avoid ambiguity during parsing of expressions, we define the associativity of some binary operators.
As well, the table lists the operators in order of precedence, from lower to higher.

| **Operator family** | **Operators** | **Associates** |
|---------------------|---------------|----------------|
| Block               | ,             | Left           |
| Ternary condition   | ? :           | Right          |
| Equality            | == !=         | Left           |
| Comparison          | > >= < <=     | Left           |
| Term                | - +           | Left           |
| Factor              | / *           | Left           |
| Unary               | ! -           | Right          |
