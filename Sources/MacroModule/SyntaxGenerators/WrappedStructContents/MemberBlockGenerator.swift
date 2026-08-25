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
        inheritance: Inheritance
    ) -> MemberBlockSyntax {
        let enumTypeSyntax = IdentifierTypeSyntax(name: declaration.name)

        return MemberBlockSyntax(
            leadingTrivia: declaration.memberBlock.leadingTrivia,
            members: MemberBlockItemListSyntax {
                valueTypealias(enumTypeSyntax: enumTypeSyntax)
                wrapperStructVariableSyntax
                wrapperStructInitSyntax
                wrapperStructCaseConstants(cases: cases)
                InheritanceClauseGenerator.generate(inheritance: inheritance)
            },
            trailingTrivia: declaration.memberBlock.trailingTrivia
        )
    }

    /// Generates the value property.
    ///
    /// Example:
    /// `typealias WrappedValue = <ENUM_NAME>`
    private static func valueTypealias(enumTypeSyntax: some TypeSyntaxProtocol) -> some DeclSyntaxProtocol {
        VariableDeclSyntax(
            bindingSpecifier: .keyword(.typealias),
            bindings: PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: .wrappedValueTypeIdentifier,
                    initializer: InitializerClauseSyntax(
                        value: TypeExprSyntax(type: enumTypeSyntax)
                    )
                )
            }
        )
    }

    /// Generates the value property.
    ///
    /// Example:
    /// `let wrappedValue: WrappedValue`
    private static var wrapperStructVariableSyntax: some DeclSyntaxProtocol {
        VariableDeclSyntax(
            leadingTrivia: .newlines(2),
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
            modifiers: DeclModifierListSyntax {
                .private
            },
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
    /// `public static let <ENUM_CASE> = Self(value: .<ENUM_CASE>)`
    private static func wrapperStructCaseConstants(cases: [EnumCaseElementSyntax]) -> [some DeclSyntaxProtocol] {
        cases.map { caseSyntax in
            VariableDeclSyntax(
                leadingTrivia: caseSyntax.leadingTrivia,
                modifiers: DeclModifierListSyntax(arrayLiteral: .public, .static),
                .let,
                name: PatternSyntax(stringLiteral: caseSyntax.name.text),
                initializer: InitializerClauseSyntax(
                    value: FunctionCallExprSyntax(
                        calledExpression: DeclReferenceExprSyntax(baseName: .keyword(.Self)),
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
