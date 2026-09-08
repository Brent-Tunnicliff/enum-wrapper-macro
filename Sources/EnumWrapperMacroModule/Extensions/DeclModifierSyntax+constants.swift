// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax

extension DeclModifierSyntax {
    static let `private` = DeclModifierSyntax(name: .keyword(.private))
    static let `public` = DeclModifierSyntax(name: .keyword(.public))
    static let `static` = DeclModifierSyntax(name: .keyword(.static))
}
