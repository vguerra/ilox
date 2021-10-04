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

expression  = grouping / unary / binary / literal

grouping    = "(" expression ")"

unary       = ("-" / "!") expression

binary      = expression operator expression

operator    = "==" / "!=" / "<" / "<=" / ">" /
              ">=" / "+" / "-" / "*" / "/"

literal     = 1*DIGIT"."1*DIGIT / 1*ALPHA /
              "true" / "false" / "nil"
```

Find the definition in the [lox.abnf](grammar/lox.abnf) file.
