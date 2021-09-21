//
//  Expression.swift
//  All objects representing expressions in the Abstract Syntaxt Tree
//
//  Created by Victor Manuel Guerra Moran on 16/09/2021.
//

class Expression {

}

final class Binary : Expression {
    let left: Expression
    let right: Expression
    let op: Token

    init(_ left:Expression, _ op:Token, _ r ight: Expression) {
        self.left = left
        self.right = right
        self.op = op
        super.init()
    }
}
