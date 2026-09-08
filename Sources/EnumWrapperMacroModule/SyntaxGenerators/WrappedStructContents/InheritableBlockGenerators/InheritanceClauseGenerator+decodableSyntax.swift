// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder

extension WrapperStructGenerator.MemberBlockGenerator.InheritanceClauseGenerator {
    /// Generates `DecodableSyntax` wrapper.
    ///
    /// Example:
    /// ```
    /// // MARK: Decodable
    ///
    /// public init(from decoder: any Decoder) throws {
    ///     self.wrappedValue = try WrappedValue(from: decoder)
    /// }
    /// ```
    static let decodableSyntax: some DeclSyntaxProtocol =
        InitializerDeclSyntax(
            leadingTrivia: .inheritanceLeadingTrivia(.decodable),
            modifiers: DeclModifierListSyntax(arrayLiteral: .public),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            firstName: "from",
                            secondName: "decoder",
                            type: TypeSyntax(
                                CompositionTypeSyntax(
                                    elements: CompositionTypeElementListSyntax {
                                        CompositionTypeElementSyntax(type: IdentifierTypeSyntax(name: .keyword(.any)))
                                        CompositionTypeElementSyntax(type: IdentifierTypeSyntax(name: "Decoder"))
                                    }
                                )
                            )
                        )
                    }
                ),
                effectSpecifiers: FunctionEffectSpecifiersSyntax(
                    throwsClause: ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws))
                )
            ),
            body: CodeBlockSyntax {
                // self.wrappedValue = try WrappedValue(from: decoder)
                CodeBlockItemSyntax(
                    item: .expr(
                        ExprSyntax(
                            SequenceExprSyntax {
                                MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(baseName: .keyword(.self)),
                                    declName: .wrappedValue
                                )

                                AssignmentExprSyntax()

                                TryExprSyntax(
                                    expression: FunctionCallExprSyntax(
                                        calledExpression: .wrappedValueTypeDeclReference,
                                        leftParen: .leftParenToken(),
                                        rightParen: .rightParenToken()
                                    ) {
                                        LabeledExprSyntax(
                                            label: "from",
                                            expression: DeclReferenceExprSyntax(baseName: "decoder")
                                        )
                                    }
                                )
                            }
                        )
                    )
                )
            }
        )
}
