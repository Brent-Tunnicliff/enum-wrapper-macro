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
            containsRawValue: rawValue != nil,
            inheritedTypes: inheritedTypes
        )
        return Inheritance(rawValue: rawValue, protocols: supportedProtocolTypes)
    }

    private func rawValueType(
        context: some MacroExpansionContext,
        inheritedTypes: InheritedTypeListSyntax
    ) -> Inheritance.RawValueItem? {
        let inheritedRawValueTypes: [Inheritance.RawValueItem] = inheritedTypes.compactMap(mapRawValueItem)

        // We only want the first or nil if none, if there are more than that then something is wrong.
        guard inheritedRawValueTypes.count < 2 else {
            context.diagnose(.tooManyRawValueTypes(node: self))
            return nil
        }

        return inheritedRawValueTypes.first
    }

    private func mapRawValueItem(inheritedTypeSyntax: InheritedTypeSyntax) -> Inheritance.RawValueItem? {
        guard
            let type = inheritedTypeSyntax.type.as(IdentifierTypeSyntax.self),
            let rawValueType = RawValueSupportedInheritanceType(rawValue: type.name.text)
        else {
            return nil
        }

        return Inheritance.RawValueItem(
            type: rawValueType,
            syntax: InheritedTypeSyntax(
                type: IdentifierTypeSyntax(name: .identifier(rawValueType.rawValue))
            )
        )
    }

    private func supportedProtocolTypes(
        containsRawValue: Bool,
        inheritedTypes: InheritedTypeListSyntax,
    ) -> [Inheritance.ProtocolItem] {
        let declaredTypes: [Inheritance.ProtocolItem] = inheritedTypes.compactMap(mapProtocolItem)
        return declaredTypes + autoConformProtocols(declaredTypes: declaredTypes)
    }

    /// There are protocol types that enums always conform to when they do not have associated values.
    private func autoConformProtocols(declaredTypes: [Inheritance.ProtocolItem]) -> [Inheritance.ProtocolItem] {
        ProtocolSupportedInheritanceType.autoProtocolInheritanceTypes.compactMap { type in
            guard !declaredTypes.contains(where: { $0.type == type }) else {
                return nil
            }

            return Inheritance.ProtocolItem(type: type)
        }
    }

    private func mapProtocolItem(inheritedTypeSyntax: InheritedTypeSyntax) -> Inheritance.ProtocolItem? {
        guard
            let identifierTypeSyntax = inheritedTypeSyntax.type.as(IdentifierTypeSyntax.self),
            let typeName = ProtocolSupportedInheritanceType.TypeName(rawValue: identifierTypeSyntax.name.text),
            let type = mapProtocolItemType(from: typeName, identifierTypeSyntax: identifierTypeSyntax)
        else {
            return nil
        }

        return Inheritance.ProtocolItem(type: type)
    }

    private func mapProtocolItemType(
        from typeName: ProtocolSupportedInheritanceType.TypeName,
        identifierTypeSyntax: IdentifierTypeSyntax
    ) -> ProtocolSupportedInheritanceType? {
        switch typeName {
        case .caseIterable: .caseIterable
        case .codable: .codable
        case .comparable: .comparable
        case .customDebugStringConvertible: .customDebugStringConvertible
        case .customStringConvertible: .customStringConvertible
        case .decodable: .decodable
        case .encodable: .encodable
        case .equatable: .equatable
        case .hashable: .hashable
        case .identifiable: identifiableProtocolItemType(identifierTypeSyntax: identifierTypeSyntax)
        case .sendable: .sendable
        }
    }

    private func extractGenericTypeName(from identifierTypeSyntax: IdentifierTypeSyntax) -> String? {
        guard let argument = identifierTypeSyntax.genericArgumentClause?.arguments.first?.argument else {
            return nil
        }

        switch argument {
        case let .expr(syntax):
            return syntax.as(DeclReferenceExprSyntax.self)?.baseName.trimmed.text
        case let .type(syntax):
            return syntax.as(IdentifierTypeSyntax.self)?.trimmed.name.trimmed.text
        }
    }

    private func extractTypealiasTypeName(
        from identifierTypeSyntax: IdentifierTypeSyntax,
        name: String
    ) -> String? {
        memberBlock.members
            .compactMap { (item: MemberBlockItemSyntax) -> String? in
                guard
                    let member = TypeAliasDeclSyntax(item.decl),
                    let rawValue = member.initializer.value.as(IdentifierTypeSyntax.self)?.name,
                    member.name.trimmed.text == name
                else {
                    return nil
                }

                return rawValue.trimmed.text
            }
            .first
    }

    private func extractVariableTypeName(
        from identifierTypeSyntax: IdentifierTypeSyntax,
        name: String,
        excluding nameToExclude: String
    ) -> String? {
        memberBlock.members
            .compactMap { (item: MemberBlockItemSyntax) -> String? in
                guard let variable = VariableDeclSyntax(item.decl) else {
                    return nil
                }

                // Find the first case of the variable without the excluded type.
                return variable.bindings
                    .compactMap { (binding: PatternBindingSyntax) -> String? in
                        guard
                            binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed.text == name,
                            let type = binding.typeAnnotation?.type,
                            let typeSyntax = type.as(IdentifierTypeSyntax.self)?.name.trimmed.text,
                            typeSyntax != nameToExclude
                        else {
                            return nil
                        }

                        return typeSyntax
                    }
                    .first
            }
            .first
    }

    /// Attempts to work out the Identifiable type.
    private func identifiableProtocolItemType(
        identifierTypeSyntax: IdentifierTypeSyntax
    ) -> ProtocolSupportedInheritanceType? {
        let rawValue = extractGenericTypeName(from: identifierTypeSyntax)
            ?? extractTypealiasTypeName(from: identifierTypeSyntax, name: "ID")
            ?? extractVariableTypeName(from: identifierTypeSyntax, name: "id", excluding: "ID")

        return rawValue.map { .identifiable($0) }
    }
}

extension DiagnosticMessage {
    fileprivate static func tooManyRawValueTypes(node: some SyntaxProtocol) -> DiagnosticMessage {
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
        protocols: ProtocolSupportedInheritanceType.autoProtocolInheritanceTypes.map(ProtocolItem.init(type:))
    )

    private static let rawRepresentableSyntax = InheritedTypeSyntax(
        type: IdentifierTypeSyntax(name: "RawRepresentable")
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
