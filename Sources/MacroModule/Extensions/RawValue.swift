// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax

extension TokenSyntax {
    static let rawValue: TokenSyntax = .identifier("rawValue")
}

extension IdentifierPatternSyntax {
    static let rawValue = IdentifierPatternSyntax(identifier: .rawValue)
}

extension PatternSyntaxProtocol where Self == IdentifierPatternSyntax {
    static var rawValueIdentifier: Self { .rawValue }
}
