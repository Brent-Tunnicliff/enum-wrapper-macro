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
        guard inheritedTypes.count < 2 else {
            context.diagnose(.tooRawValueTypes(node: self) )
            return nil
        }

        guard
            let inheritedTypeSyntax = inheritedTypes.first,
            let rawValueType = RawValueSupportedInheritanceType(inheritedTypeSyntax: inheritedTypeSyntax)
        else {
            return nil
        }

        return Inheritance.Item(type: rawValueType, syntax: inheritedTypeSyntax)
    }

    private func supportedProtocolTypes(
        context: some MacroExpansionContext,
        containsRawValue: Bool,
        inheritedTypes: InheritedTypeListSyntax,
    ) -> [Inheritance.ProtocolItem] {
        let declaredTypes: [Inheritance.ProtocolItem] = inheritedTypes
            .compactMap { inheritedTypeSyntax in
                guard let protocolType = ProtocolSupportedInheritanceType(inheritedTypeSyntax: inheritedTypeSyntax) else {
                    return nil
                }

                return Inheritance.ProtocolItem(type: protocolType, syntax: inheritedTypeSyntax)
            }

        guard containsRawValue else {
            return declaredTypes
        }

        // The RawValues that we support can auto conform to some protocols,
        // so we want to also cover those.
        // Plus we always want Sendable.
        let autoConformProtocols: [ProtocolSupportedInheritanceType] = [.sendable]
            + RawValueSupportedInheritanceType.autoProtocolInheritanceTypes

        let autoConformTypes: [Inheritance.ProtocolItem] = autoConformProtocols
            .compactMap { protocolType in
                let alreadyDeclared = declaredTypes.contains(where: { protocolType == $0.type })
                guard !alreadyDeclared else {
                    return nil
                }

                return Inheritance.ProtocolItem(
                    type: protocolType,
                    syntax: InheritedTypeSyntax(
                        type: IdentifierTypeSyntax(name: .identifier(protocolType.rawValue))
                    )
                )
            }

        return declaredTypes + autoConformTypes
    }
}

extension DiagnosticMessage {
    fileprivate static func tooRawValueTypes(node: some SyntaxProtocol) -> DiagnosticMessage {
        DiagnosticMessage(
            message: "Only 1 or more raw value types are supported.",
            node: node,
            severity: .error
        )
    }
}

extension Inheritance {
    // We always want `Sendable` as the enum types we wrap are inherently Sendable anyway.
    fileprivate static let `default` = Inheritance(
        rawValue: nil,
        protocols: [
            ProtocolItem(
                type: .sendable,
                syntax: InheritedTypeSyntax(type: .sendableProtocol)
            )
        ]
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
