// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

/// All the protocol types we support wrapping as each one requires manually defining.
enum ProtocolSupportedInheritanceType: Hashable, Sendable {
    case caseIterable
    case codable
    case comparable
    case customDebugStringConvertible
    case customStringConvertible
    case decodable
    case encodable
    case equatable
    case hashable
    case identifiable(String)
    case sendable
}

extension ProtocolSupportedInheritanceType {
    enum TypeName: String, CaseIterable {
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
    }

    var typeName: TypeName {
        switch self {
        case .caseIterable: .caseIterable
        case .codable: .codable
        case .comparable: .comparable
        case .customDebugStringConvertible: .customDebugStringConvertible
        case .customStringConvertible: .customStringConvertible
        case .decodable: .decodable
        case .encodable: .encodable
        case .equatable: .equatable
        case .hashable: .hashable
        case .identifiable: .identifiable
        case .sendable: .sendable
        }
    }
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
