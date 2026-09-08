// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax

struct Inheritance: Sendable {
    let rawValue: RawValueItem?
    let protocols: [ProtocolItem]
}

extension Inheritance {
    typealias RawValueItem = Item<RawValueSupportedInheritanceType>
    typealias ProtocolItem = Item<ProtocolSupportedInheritanceType>

    struct Item<InheritanceType>: Sendable where InheritanceType: Sendable {
        let type: InheritanceType
        let syntax: InheritedTypeSyntax
    }
}

extension Inheritance.ProtocolItem {
    /// Creates a new inheritance that does not derive from existing syntax.
    init(type: InheritanceType) {
        self.init(
            type: type,
            syntax: InheritedTypeSyntax(
                type: IdentifierTypeSyntax(name: .identifier(type.typeName.rawValue))
            )
        )
    }
}
