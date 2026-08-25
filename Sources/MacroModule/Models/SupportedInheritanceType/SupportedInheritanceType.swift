// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxMacros

/// Types we support for inheritance.
protocol SupportedInheritanceType: RawRepresentable, Sendable {}

extension SupportedInheritanceType where RawValue == String {
    init?(inheritedTypeSyntax: InheritedTypeSyntax) {
        guard let type = inheritedTypeSyntax.type.as(IdentifierTypeSyntax.self) else {
            return nil
        }

        self.init(rawValue: type.name.text)
    }
}
