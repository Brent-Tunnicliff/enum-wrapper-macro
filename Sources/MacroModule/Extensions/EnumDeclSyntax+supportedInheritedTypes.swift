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

    /// Attempts to work out the Identifiable type.
    private func identifiableProtocolItemType(
        identifierTypeSyntax: IdentifierTypeSyntax
    ) -> ProtocolSupportedInheritanceType? {
        identifiableProtocolItemTypeFromGenericArgument(identifierTypeSyntax: identifierTypeSyntax)
            ?? identifiableProtocolItemTypeFromTypealias(identifierTypeSyntax: identifierTypeSyntax)
            ?? identifiableProtocolItemTypeFromMemberBlockVariable(identifierTypeSyntax: identifierTypeSyntax)
    }

    // If using genericArgumentClause e.g. `Identifiable<String>`
    private func identifiableProtocolItemTypeFromGenericArgument(
        identifierTypeSyntax: IdentifierTypeSyntax
    ) -> ProtocolSupportedInheritanceType? {
        guard let argument = identifierTypeSyntax.genericArgumentClause?.arguments.first?.argument else {
            return nil
        }

        let rawValue: String?
        switch argument {
        case let .expr(syntax):
            rawValue = syntax.as(DeclReferenceExprSyntax.self)?.baseName.trimmed.text
        case let .type(syntax):
            rawValue = syntax.as(IdentifierTypeSyntax.self)?.trimmed.name.trimmed.text
        }

        guard let rawValue else {
            return nil
        }

        return .identifiable(rawValue)
    }

    // If declared as a ID type in the member body.
    private func identifiableProtocolItemTypeFromTypealias(
        identifierTypeSyntax: IdentifierTypeSyntax
    ) -> ProtocolSupportedInheritanceType? {
        let rawValue = memberBlock.members
            .compactMap { (item: MemberBlockItemSyntax) -> String? in
                guard
                    let member = TypeAliasDeclSyntax(item.decl),
                    let rawValue = member.initializer.value.as(IdentifierTypeSyntax.self)?.name,
                    member.name.trimmed.text == "ID"
                else {
                    return nil
                }

                return rawValue.trimmed.text
            }
            .first

        guard let rawValue else {
            return nil
        }

        return .identifiable(rawValue)
    }

    // If declared as a variable in the member body.
    private func identifiableProtocolItemTypeFromMemberBlockVariable(
        identifierTypeSyntax: IdentifierTypeSyntax
    ) -> ProtocolSupportedInheritanceType? {
        let rawValue: String? = memberBlock.members
            .compactMap { (item: MemberBlockItemSyntax) -> String? in
                guard let variable = VariableDeclSyntax(item.decl) else {
                    return nil
                }

                // Find any cases of the variable `id` with a type that is not the generic `ID`.
                return variable.bindings
                    .compactMap { (binding: PatternBindingSyntax) -> String? in
                        guard
                            binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed.text == "id",
                            let type = binding.typeAnnotation?.type,
                            let typeSyntax = type.as(IdentifierTypeSyntax.self)?.name.trimmed.text,
                            typeSyntax != "ID"
                        else {
                            return nil
                        }

                        return typeSyntax
                    }
                    .first
            }
            .first

        guard let rawValue else {
            return nil
        }

        return .identifiable(rawValue)
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
