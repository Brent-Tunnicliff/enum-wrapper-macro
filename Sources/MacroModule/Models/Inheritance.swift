// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax

struct Inheritance: Sendable {
    let rawValue: RawValueItem?
    let protocols: [ProtocolItem]
}

extension Inheritance {
    typealias RawValueItem = Item<RawValueSupportedInheritanceType>
    typealias ProtocolItem = Item<ProtocolSupportedInheritanceType>

    struct Item<InheritanceType>: Sendable where InheritanceType: SupportedInheritanceType {
        let type: InheritanceType
        let syntax: InheritedTypeSyntax
    }
}
