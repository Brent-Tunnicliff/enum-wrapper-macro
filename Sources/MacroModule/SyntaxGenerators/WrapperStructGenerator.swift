// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum WrapperStructGenerator {
    private static let wrapperNameSuffix = "Wrapper"

    /// Generates the struct that is a wrapper of the input enum type.
    ///
    /// Example:
    /// ```
    /// /// Any documentation from the wrapped enum.
    /// public struct <ENUM_NAME>Wrapper: Sendable, <ENUM_INHERITANCES> {
    ///     typealias WrappedValue = <ENUM_NAME>
    ///
    ///     let wrappedValue: WrappedValue
    ///
    ///     private init(wrappedValue: WrappedValue) {
    ///         self.wrappedValue = wrappedValue
    ///     }
    ///
    ///     /// Any documentation for from the wrapped enum case.
    ///     public static let <ENUM_CASE> = Self.init(wrappedValue: .<ENUM_CASE>)
    ///
    ///     // Any inheritable conformances that just call `value`.
    /// }
    /// ```
    static func generate(
        declaration: EnumDeclSyntax,
        context: some MacroExpansionContext,
        accessLevel: TokenSyntax
    ) -> DeclSyntax {
        let inheritance = declaration.supportedInheritedTypes(context: context)

        return DeclSyntax(
            StructDeclSyntax(
                leadingTrivia: declaration.leadingTrivia,
                attributes: filteredAttributes(declaration: declaration),
                modifiers: DeclModifierListSyntax(
                    arrayLiteral: DeclModifierSyntax(name: accessLevel)
                ),
                name: structName(from: declaration),
                inheritanceClause: inheritance.asInheritanceClauseSyntax,
                memberBlock: MemberBlockGenerator.generate(
                    declaration: declaration,
                    cases: declaration.extractCases(context: context),
                    inheritance: inheritance,
                    accessLevel: accessLevel
                ),
                trailingTrivia: declaration.trailingTrivia
            )
        )
    }

    private static func structName(from declaration: EnumDeclSyntax) -> TokenSyntax {
        "\(declaration.name.trimmed)\(raw: wrapperNameSuffix)"
    }

    private static func filteredAttributes(declaration: EnumDeclSyntax) -> AttributeListSyntax {
        declaration.attributes.trimmed
            .filter { element in
                switch element {
                case let .attribute(syntax):
                    // We need to filter out our own macro to avoid a loop build failure.
                    (IdentifierTypeSyntax(syntax.attributeName)?.name.trimmed.text ?? "") != "EnumWrapper"
                case .ifConfigDecl:
                    true
                }
            }
            .with(\.trailingTrivia, .newline)
    }
}
