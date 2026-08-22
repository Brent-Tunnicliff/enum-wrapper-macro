// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder

extension WrapperStructGenerator {
    enum MemberBlockGenerator {}
}

extension WrapperStructGenerator.MemberBlockGenerator {
    private static let variableName: TokenSyntax = .identifier("value")
    private static let variableNameSyntax = IdentifierPatternSyntax(identifier: variableName)
    private static let variableReferenceSyntax = DeclReferenceExprSyntax(baseName: variableName)

    /// Generates the contents of the wrapper struct block.
    static func generate(declaration: EnumDeclSyntax, cases: [EnumCaseElementSyntax]) -> MemberBlockSyntax {
        let enumTypeSyntax = IdentifierTypeSyntax(name: declaration.name)
        return MemberBlockSyntax(
            leadingTrivia: declaration.memberBlock.leadingTrivia,
            members: MemberBlockItemListSyntax {
                wrapperStructVariableSyntax(enumTypeSyntax: enumTypeSyntax)
                    .with(\.trailingTrivia, .newlines(2))

                wrapperStructInitSyntax(enumTypeSyntax: enumTypeSyntax)
                    .with(\.trailingTrivia, .newline)

                wrapperStructCaseConstants(cases: cases)
            },
            trailingTrivia: declaration.memberBlock.trailingTrivia
        )
    }

    /// Generated the value property.
    ///
    /// Example:
    /// `let value: <ENUM_NAME>`
    private static func wrapperStructVariableSyntax(
        enumTypeSyntax: some TypeSyntaxProtocol
    ) -> some DeclSyntaxProtocol {
        VariableDeclSyntax(
            .let,
            name: PatternSyntax(variableNameSyntax),
            type: TypeAnnotationSyntax(type: enumTypeSyntax)
        )
    }

    /// Generates the initialiser.
    ///
    /// Example:
    /// ```
    /// private init(value: <ENUM_NAME>) {
    ///     self.value = value
    /// }
    /// ```
    private static func wrapperStructInitSyntax(enumTypeSyntax: some TypeSyntaxProtocol) -> some DeclSyntaxProtocol {
        InitializerDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.private))
            },
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            firstName: variableName,
                            type: enumTypeSyntax
                        )
                    }
                )
            ),
            body: CodeBlockSyntax {
                CodeBlockItemSyntax(
                    item: .expr(
                        ExprSyntax(
                            SequenceExprSyntax(
                                elements: ExprListSyntax {
                                    MemberAccessExprSyntax(
                                        base: DeclReferenceExprSyntax(baseName: .keyword(.`self`)),
                                        declName: variableReferenceSyntax
                                    )

                                    AssignmentExprSyntax()

                                    variableReferenceSyntax
                                }
                            )
                        )
                    )
                )
            }
        )
    }

    /// Generates the constant wrappers of each case.
    ///
    /// Example:
    /// `public static let <ENUM_CASE> = Self(value: .<ENUM_CASE>)`
    private static func wrapperStructCaseConstants(cases: [EnumCaseElementSyntax]) -> [some DeclSyntaxProtocol] {
        cases.map { caseSyntax in
            VariableDeclSyntax(
                leadingTrivia: caseSyntax.leadingTrivia,
                modifiers: DeclModifierListSyntax {
                    DeclModifierSyntax(name: .keyword(.public))
                    DeclModifierSyntax(name: .keyword(.static))
                },
                .let,
                name: PatternSyntax(stringLiteral: caseSyntax.name.text),
                initializer: InitializerClauseSyntax(
                    value: FunctionCallExprSyntax(
                        calledExpression: DeclReferenceExprSyntax(baseName: .keyword(.Self)),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax([
                            LabeledExprSyntax(
                                label: variableName,
                                colon: .colonToken(),
                                expression: MemberAccessExprSyntax(
                                    period: .periodToken(),
                                    declName: DeclReferenceExprSyntax(baseName: caseSyntax.name.trimmed)
                                )
                            )
                        ]),
                        rightParen: .rightParenToken()
                    )
                )
            )
        }
    }
}
