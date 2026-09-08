// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax

extension TypeSyntaxProtocol where Self == IdentifierTypeSyntax {
    // I think technically the `Sendable` keyword is a different reference to the Sendable protocol.
    // But it works since they have the same name and I prefer using symbols over hard coded Strings.
    static var sendableProtocol: IdentifierTypeSyntax {
        IdentifierTypeSyntax(name: .keyword(.Sendable))
    }
}
