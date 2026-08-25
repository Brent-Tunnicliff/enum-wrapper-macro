// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum WrapperStructGenerator {
    private static let wrapperNameSuffix = "Wrapper"

    /// Generates the struct that is a wrapper of the inout enum type.
    ///
    /// Example:
    /// ```
    /// /// Any documentation from the wrapped enum.
    /// public struct <ENUM_NAME>Wrapper: Sendable, <ENUM_INHERITANCES> {
    ///     let value: <ENUM_NAME>
    ///
    ///     private init(value: <ENUM_NAME>) {
    ///         self.value = value
    ///     }
    ///
    ///     /// Any documentation for from the wrapped enum case.
    ///     public static let <ENUM_CASE> = <ENUM_NAME>Wrapper(value: .<ENUM_CASE>)
    ///
    ///     // Any inheritable conformances that just call `value`.
    /// }
    /// ```
    static func generate(
        declaration: EnumDeclSyntax,
        context: some MacroExpansionContext
    ) -> DeclSyntax {
        let inheritance = declaration.supportedInheritedTypes(context: context)

        return DeclSyntax(
            StructDeclSyntax(
                leadingTrivia: declaration.leadingTrivia,
                modifiers: DeclModifierListSyntax {
                    .public
                },
                name: structName(from: declaration),
                inheritanceClause: inheritance.asInheritanceClauseSyntax,
                memberBlock: MemberBlockGenerator.generate(
                    declaration: declaration,
                    cases: declaration.extractCases(context: context),
                    inheritance: inheritance
                ),
                trailingTrivia: declaration.trailingTrivia
            )
        )
    }

    private static func structName(from declaration: EnumDeclSyntax) -> TokenSyntax {
        .identifier("\(declaration.name.text)\(wrapperNameSuffix)")
    }
}
