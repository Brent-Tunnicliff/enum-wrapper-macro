// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

extension InheritedTypeSyntax {
    var isSendable: Bool {
        get throws {
            guard let typeSyntax = IdentifierTypeSyntax(type) else {
                throw InternalMacroError(
                    "Unexpected type '\(type)', unable to cast to 'IdentifierTypeSyntax'."
                )
            }

            return typeSyntax.name.text.contains(IdentifierTypeSyntax.sendableProtocol.trimmedDescription)
        }
    }
}
