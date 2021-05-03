//
//  GenericArrayBuilder.swift
//  
//
//  Created by Russell Warwick on 01/05/2021.
//

import Foundation

@_functionBuilder
public struct GenericArrayBuilder<I> {

    typealias Expression = I
    typealias Component = [I]

    static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }

    static func buildExpression(_ expression: Component) -> Component {
        return expression
    }

    static func buildExpression(_ expression: Expression?) -> Component {
        guard let expression = expression else { return [] }
        return [expression]
    }

    static func buildBlock(_ children: Component...) -> Component {
        return children.flatMap { $0 }
    }

    static func buildBlock(_ component: Component) -> Component {
        return component
    }

    static func buildOptional(_ children: Component?) -> Component {
        return children ?? []
    }

    static func buildEither(first child: Component) -> Component {
        return child
    }

    static func buildEither(second child: Component) -> Component {
        return child
    }

    static func buildArray(_ components: [Component]) -> Component {
        return components.flatMap { $0 }
    }
    
    
}
