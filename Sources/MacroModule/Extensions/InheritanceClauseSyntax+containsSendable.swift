// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax

extension InheritanceClauseSyntax {
    var containsSendable: Bool {
        get throws {
            try inheritedTypes.contains(where: { try $0.isSendable })
        }
    }
}
