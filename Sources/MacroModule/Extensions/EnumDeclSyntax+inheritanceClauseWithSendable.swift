// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder

extension EnumDeclSyntax {
    private static let sendableInheritedTypeSyntax = InheritedTypeSyntax(
        type: IdentifierTypeSyntax(name: .keyword(.Sendable))
    )

    /// Injects Sendable inheritance if missing.
    ///
    /// The simple enums we wrap are inherently Sendable, so we still want to mirror that.
    var inheritanceClauseWithSendable: InheritanceClauseSyntax {
        get throws {
            guard let inheritanceClause else {
                return InheritanceClauseSyntax(
                    inheritedTypes: InheritedTypeListSyntax {
                        Self.sendableInheritedTypeSyntax
                    }
                )
            }

            // If sendable exists no need to inject it
            guard try !inheritanceClause.containsSendable else {
                return inheritanceClause
            }

            return InheritanceClauseSyntax(
                inheritedTypes: InheritedTypeListSyntax {
                    inheritanceClause.inheritedTypes
                    Self.sendableInheritedTypeSyntax
                }
            )
        }
    }
}
