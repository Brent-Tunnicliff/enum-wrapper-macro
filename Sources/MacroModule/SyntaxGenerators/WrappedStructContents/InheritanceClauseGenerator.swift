// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension WrapperStructGenerator.MemberBlockGenerator {
    enum InheritanceClauseGenerator {}
}

extension WrapperStructGenerator.MemberBlockGenerator.InheritanceClauseGenerator {
    /// Generates the contents of the Inheritance types.
    static func generate(inheritance: Inheritance) -> [any DeclSyntaxProtocol] {
        let rawValueResults: [any DeclSyntaxProtocol]
        if let rawValueType = inheritance.rawValue?.type {
            rawValueResults = rawRepresentableSyntax(for: rawValueType)
        } else {
            rawValueResults = []
        }

        return rawValueResults + generateProtocolSyntax(inheritance: inheritance)
    }

    private static func generateProtocolSyntax(inheritance: Inheritance) -> [any DeclSyntaxProtocol] {
        var addedTypes: Set<ProtocolSupportedInheritanceType> = []
        var results: [any DeclSyntaxProtocol] = []

        for protocolType in inheritance.protocols.map(\.type) {
            // We must skip any duplicates.
            for (type, syntax) in generateSyntax(for: protocolType) where !addedTypes.contains(protocolType) {
                results.append(contentsOf: syntax)
                addedTypes.insert(type)
            }
        }

        return results
    }

    fileprivate typealias GenerateSyntaxResult = (
        type: ProtocolSupportedInheritanceType,
        syntax: [any DeclSyntaxProtocol]
    )

    private static func generateSyntax(for protocolType: ProtocolSupportedInheritanceType) -> [GenerateSyntaxResult] {
        switch protocolType {
        // No code generation needed.
        case .equatable, .hashable, .sendable: [(protocolType, [])]

        // Generate Decodable and Encodable separately instead of one Codable.
        case .codable: [(.decodable, [decodableSyntax]), (.encodable, [encodableSyntax])]

        case .caseIterable: [(protocolType, [caseIterableSyntax])]
        case .comparable: [(protocolType, comparableSyntax)]
        case .customDebugStringConvertible: [(protocolType, [customDebugStringConvertibleSyntax])]
        case .customStringConvertible: [(protocolType, [customStringConvertibleSyntax])]
        case .decodable: [(protocolType, [decodableSyntax])]
        case .encodable: [(protocolType, [encodableSyntax])]
        case let .identifiable(value): [(protocolType, [identifiableSyntax(for: value)])]
        }
    }
}
