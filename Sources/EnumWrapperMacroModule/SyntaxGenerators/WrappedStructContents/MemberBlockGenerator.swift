// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder

extension WrapperStructGenerator {
    enum MemberBlockGenerator {}
}

extension WrapperStructGenerator.MemberBlockGenerator {
    /// Generates the contents of the wrapper struct block.
    static func generate(
        declaration: EnumDeclSyntax,
        cases: [EnumCaseElementSyntax],
        inheritance: Inheritance,
        accessLevel: TokenSyntax
    ) -> MemberBlockSyntax {
        MemberBlockSyntax(
            leadingTrivia: declaration.memberBlock.leadingTrivia,
            members: MemberBlockItemListSyntax {
                valueTypealias(declaration: declaration)
                wrapperStructVariableSyntax(declaration: declaration)
                wrapperStructInitSyntax
                wrapperStructCaseConstants(cases: cases, accessLevel: accessLevel)
                InheritanceClauseGenerator.generate(inheritance: inheritance)
            },
            trailingTrivia: declaration.memberBlock.trailingTrivia
        )
    }

    /// Generates the value property.
    ///
    /// Example:
    /// `typealias WrappedValue = <ENUM_NAME>`
    private static func valueTypealias(declaration: EnumDeclSyntax) -> some DeclSyntaxProtocol {
        TypeAliasDeclSyntax(
            modifiers: declaration.modifiers.trimmed,
            name: .wrappedValueType,
            initializer: TypeInitializerClauseSyntax(value: IdentifierTypeSyntax(name: declaration.name))
        )
    }

    /// Generates the value property.
    ///
    /// Example:
    /// `let wrappedValue: WrappedValue`
    private static func wrapperStructVariableSyntax(declaration: EnumDeclSyntax) -> some DeclSyntaxProtocol {
        VariableDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: declaration.modifiers.trimmed,
            .let,
            name: PatternSyntax(IdentifierPatternSyntax(identifier: .wrappedValue)),
            type: TypeAnnotationSyntax(type: .wrappedValueIdentifierType)
        )
    }

    /// Generates the initialiser.
    ///
    /// Example:
    /// ```
    /// private init(wrappedValue: WrappedValue) {
    ///     self.wrappedValue = wrappedValue
    /// }
    /// ```
    private static var wrapperStructInitSyntax: some DeclSyntaxProtocol {
        InitializerDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: DeclModifierListSyntax(arrayLiteral: .private),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            firstName: .wrappedValue,
                            type: .wrappedValueIdentifierType
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
                                        declName: .wrappedValue
                                    )

                                    AssignmentExprSyntax()

                                    DeclReferenceExprSyntax.wrappedValue
                                }
                            )
                        )
                    )
                )
            },
            trailingTrivia: .newlines(2)
        )
    }

    /// Generates the constant wrappers of each case.
    ///
    /// Example:
    /// `public static let <ENUM_CASE> = Self.init(wrappedValue: .<ENUM_CASE>)`
    private static func wrapperStructCaseConstants(
        cases: [EnumCaseElementSyntax],
        accessLevel: TokenSyntax
    ) -> [some DeclSyntaxProtocol] {
        cases.map { caseSyntax in
            VariableDeclSyntax(
                leadingTrivia: caseSyntax.leadingTrivia,
                modifiers: DeclModifierListSyntax(
                    arrayLiteral: DeclModifierSyntax(name: accessLevel), .static
                ),
                .let,
                name: PatternSyntax(stringLiteral: caseSyntax.name.text),
                initializer: InitializerClauseSyntax(
                    value: FunctionCallExprSyntax(
                        calledExpression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(baseName: .keyword(.Self)),
                            name: .keyword(.`init`)
                        ),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax {
                            LabeledExprSyntax(
                                label: .wrappedValue,
                                colon: .colonToken(),
                                expression: MemberAccessExprSyntax(
                                    period: .periodToken(),
                                    declName: DeclReferenceExprSyntax(baseName: caseSyntax.name.trimmed)
                                )
                            )
                        },
                        rightParen: .rightParenToken()
                    ),
                    trailingTrivia: caseSyntax.trailingTrivia
                )
            )
        }
    }
}
