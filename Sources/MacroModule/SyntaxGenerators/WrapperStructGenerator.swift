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
    static func generate(declaration: EnumDeclSyntax, context: some MacroExpansionContext) throws -> DeclSyntax {
        DeclSyntax(
            StructDeclSyntax(
                leadingTrivia: declaration.leadingTrivia,
                modifiers: DeclModifierListSyntax {
                    DeclModifierSyntax(name: .keyword(.public))
                },
                name: structName(from: declaration),
                inheritanceClause: try declaration.inheritanceClauseWithSendable,
                memberBlock: MemberBlockGenerator.generate(
                    declaration: declaration,
                    cases: cases(of: declaration, in: context)
                ),
                trailingTrivia: declaration.trailingTrivia
            )
        )
    }

    private static func cases(
        of declaration: EnumDeclSyntax,
        in context: some MacroExpansionContext
    ) -> [EnumCaseElementSyntax] {
        var cases: [EnumCaseElementSyntax] = []

        for member in declaration.memberBlock.members {
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else {
                continue
            }

            for element in caseDecl.elements {
                guard element.parameterClause == nil else {
                    // This case has associated values, record an error and skip.
                    context.diagnose(.associatedValuesNotSupported(node: element))
                    continue
                }

                // Pass any leading trivia comments to the case elements.
                let hasNoComments = caseDecl.leadingTrivia.pieces.filter(\.isComment).isEmpty

                let leadingTrivia: Trivia
                if hasNoComments {
                    leadingTrivia = Trivia(pieces: [])
                } else {
                    leadingTrivia = Trivia(
                        pieces: caseDecl.leadingTrivia.filter { $0.isComment || $0.isNewline }
                    )
                }

                cases.append(element.with(\.leadingTrivia, leadingTrivia))
            }
        }

        return cases
    }

    private static func structName(from declaration: EnumDeclSyntax) -> TokenSyntax {
        .identifier("\(declaration.name.text)\(wrapperNameSuffix)")
    }
}
