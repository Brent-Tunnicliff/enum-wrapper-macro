// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder

extension WrapperStructGenerator.MemberBlockGenerator.InheritanceClauseGenerator {
    /// Generates `Encodable` wrapper.
    ///
    /// Example:
    /// ```
    /// // MARK: Encodable
    ///
    /// public func encode(to encoder: any Encoder) throws {
    ///     try wrappedValue.encode(to: encoder)
    /// }
    /// ```
    static let encodableSyntax: some DeclSyntaxProtocol =
        FunctionDeclSyntax(
            leadingTrivia: .inheritanceLeadingTrivia(.encodable),
            modifiers: DeclModifierListSyntax(arrayLiteral: .public),
            name: "encode",
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax {
                    FunctionParameterSyntax(
                        firstName: "to",
                        secondName: "encoder",
                        type: TypeSyntax(
                            CompositionTypeSyntax(
                                elements: CompositionTypeElementListSyntax {
                                    CompositionTypeElementSyntax(type: IdentifierTypeSyntax(name: .keyword(.any)))
                                    CompositionTypeElementSyntax(type: IdentifierTypeSyntax(name: "Encoder"))
                                }
                            )
                        )
                    )
                },
                effectSpecifiers: FunctionEffectSpecifiersSyntax(
                    throwsClause: ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws))
                )
            ),
            bodyBuilder: {
                CodeBlockItemSyntax(
                    item: .expr(
                        ExprSyntax(
                            TryExprSyntax(
                                expression: FunctionCallExprSyntax(
                                    calledExpression: MemberAccessExprSyntax(
                                        base: DeclReferenceExprSyntax.wrappedValue,
                                        name: "encode"
                                    ),
                                    leftParen: .leftParenToken(),
                                    arguments: LabeledExprListSyntax {
                                        LabeledExprSyntax(
                                            label: "to",
                                            colon: .colonToken(),
                                            expression: DeclReferenceExprSyntax(baseName: "encoder")
                                        )
                                    },
                                    rightParen: .rightParenToken()
                                )
                            )
                        )
                    )
                )
            }
        )
}
