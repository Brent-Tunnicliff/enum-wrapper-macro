// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension EnumDeclSyntax {
    /// Filters the inherited types to only include supported ones.
    func supportedInheritedTypes(context: some MacroExpansionContext) -> Inheritance {
        guard let inheritedTypes = inheritanceClause?.inheritedTypes, !inheritedTypes.isEmpty else {
            return .default
        }

        let rawValue = rawValueType(context: context, inheritedTypes: inheritedTypes)
        let supportedProtocolTypes = supportedProtocolTypes(
            context: context,
            containsRawValue: rawValue != nil,
            inheritedTypes: inheritedTypes
        )
        return Inheritance(rawValue: rawValue, protocols: supportedProtocolTypes)
    }

    private func rawValueType(
        context: some MacroExpansionContext,
        inheritedTypes: InheritedTypeListSyntax
    ) -> Inheritance.RawValueItem? {
        let inheritedRawValueTypes: [Inheritance.RawValueItem] = inheritedTypes.compactMap {
            guard let rawValueType = RawValueSupportedInheritanceType(inheritedTypeSyntax: $0) else {
                return nil
            }

            return Inheritance.RawValueItem(type: rawValueType, syntax: $0)
        }

        // We only want the first or nil if none, if there are more than that then something is wrong.
        guard inheritedRawValueTypes.count < 2 else {
            context.diagnose(.tooRawValueTypes(node: self))
            return nil
        }

        return inheritedRawValueTypes.first
    }

    private func supportedProtocolTypes(
        context: some MacroExpansionContext,
        containsRawValue: Bool,
        inheritedTypes: InheritedTypeListSyntax,
    ) -> [Inheritance.ProtocolItem] {
        let declaredTypes: [Inheritance.ProtocolItem] = inheritedTypes.compactMap { inheritedTypeSyntax in
            guard let protocolType = ProtocolSupportedInheritanceType(inheritedTypeSyntax: inheritedTypeSyntax) else {
                return nil
            }

            return Inheritance.ProtocolItem(
                type: protocolType,
                syntax: inheritedTypeSyntax
                    .with(\.leadingTrivia, [])
                    .with(\.trailingTrivia, [])
            )
        }

        return declaredTypes + autoConformProtocols(declaredTypes: declaredTypes)
    }

    /// There are protocol types that enums always conform to when they do not have associated values.
    private func autoConformProtocols(declaredTypes: [Inheritance.ProtocolItem]) -> [Inheritance.ProtocolItem] {
        ProtocolSupportedInheritanceType.autoProtocolInheritanceTypes.compactMap { type in
            guard !declaredTypes.contains(where: { $0.type == type }) else {
                return nil
            }

            return Inheritance.ProtocolItem(
                type: type,
                syntax: InheritedTypeSyntax(
                    type: IdentifierTypeSyntax(name: .identifier(type.rawValue))
                )
            )
        }
    }
}

extension DiagnosticMessage {
    fileprivate static func tooRawValueTypes(node: some SyntaxProtocol) -> DiagnosticMessage {
        DiagnosticMessage(
            message: "A maximum of 1 raw value type is supported.",
            node: node,
            severity: .error
        )
    }
}

extension Inheritance {
    fileprivate static let `default` = Inheritance(
        rawValue: nil,
        protocols: ProtocolSupportedInheritanceType.autoProtocolInheritanceTypes.map {
            ProtocolItem(
                type: $0,
                syntax: InheritedTypeSyntax(
                    type: IdentifierTypeSyntax(name: .identifier($0.rawValue))
                )
            )
        }
    )

    private static let rawRepresentableSyntax = InheritedTypeSyntax(
        type: IdentifierTypeSyntax(name: .identifier("RawRepresentable"))
    )

    var asInheritanceClauseSyntax: InheritanceClauseSyntax {
        InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                if rawValue != nil {
                    Self.rawRepresentableSyntax
                }

                protocols.map(\.syntax)
            }
        )
    }
}
