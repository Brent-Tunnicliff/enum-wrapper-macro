// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

enum SupportedIdentifiableType {
    /// We want to support the same list as RawValue inheritance.
    case rawValue(RawValueSupportedInheritanceType)

    case uuid

    /// A custom defined type.
    ///
    /// - Warning: Must be a public type that we can easily wrap. The macro is unable to check those details and relies on the build failing.
    case custom(name: String)
}

extension SupportedIdentifiableType: Hashable {}

extension SupportedIdentifiableType: RawRepresentable {
    var rawValue: String {
        switch self {
        case let .rawValue(value): value.rawValue
        case .uuid: "UUID"
        case let .custom(name): name
        }
    }

    init(rawValue: String) {
        if let rawValue = RawValueSupportedInheritanceType(rawValue: rawValue) {
            self = .rawValue(rawValue)
        } else if rawValue.uppercased() == "UUID" {
            self = .uuid
        } else {
            self = .custom(name: rawValue)
        }
    }
}
