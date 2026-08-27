// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

/// All the protocol types we support wrapping as each one requires manually defining.
enum ProtocolSupportedInheritanceType: String, CaseIterable, SupportedInheritanceType {
    case caseIterable = "CaseIterable"
    case codable = "Codable"
    case comparable = "Comparable"
    case customDebugStringConvertible = "CustomDebugStringConvertible"
    case customStringConvertible = "CustomStringConvertible"
    case decodable = "Decodable"
    case encodable = "Encodable"
    case equatable = "Equatable"
    case hashable = "Hashable"
    case identifiable = "Identifiable"
    case sendable = "Sendable"

    // Stretch goals?
    // Will look into if this is simple enough or not.
    // case strideable = "Strideable"
    // case rawRepresentable = "RawRepresentable"
}

extension ProtocolSupportedInheritanceType {
    /// Types that we should always conform to even if the enum does not.
    ///
    /// These are protocols that basic enums always conform to, even if not declared.
    static let autoProtocolInheritanceTypes: [ProtocolSupportedInheritanceType] = [
        .equatable,
        .hashable,
        .sendable,
    ]
}
