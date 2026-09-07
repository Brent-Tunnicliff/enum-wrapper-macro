// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax

extension Trivia {
    static func inheritanceLeadingTrivia(_ type: ProtocolSupportedInheritanceType.TypeName) -> Trivia {
        inheritanceLeadingTrivia(type.rawValue)
    }

    static func inheritanceLeadingTrivia(_ text: String) -> Trivia {
        [
            .newlines(2),
            .lineComment("// MARK: \(text)"),
            .newlines(2),
        ]
    }
}
