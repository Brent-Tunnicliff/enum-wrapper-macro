// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder

extension WrapperStructGenerator.MemberBlockGenerator.InheritanceClauseGenerator {
    /// Generates `Comparable` wrapper.
    ///
    /// Wraps all optional functions of `Comparable` incase the wrapped enum has custom behaviour for any.
    ///
    /// Example:
    /// ```
    /// // MARK: Comparable
    ///
    /// public static func < (lhs: Self, rhs: Self) -> Bool {
    ///     lhs.wrappedValue < rhs.wrappedValue
    /// }
    ///
    /// public static func <= (lhs: Self, rhs: Self) -> Bool {
    ///     lhs.wrappedValue <= rhs.wrappedValue
    /// }
    ///
    /// public static func >= (lhs: Self, rhs: Self) -> Bool {
    ///     lhs.wrappedValue >= rhs.wrappedValue
    /// }
    ///
    /// public static func > (lhs: Self, rhs: Self) -> Bool {
    ///     lhs.wrappedValue > rhs.wrappedValue
    /// }
    /// ```
    static let comparableSyntax: [any DeclSyntaxProtocol] = [
        (.binaryOperator("<"), .inheritanceLeadingTrivia(.comparable)),
        (.binaryOperator("<="), .newlines(2)),
        (.binaryOperator(">="), .newlines(2)),
        (.binaryOperator(">"), .newlines(2)),
    ].map { (token: TokenSyntax, leadingTrivia: Trivia) -> any DeclSyntaxProtocol in
        FunctionDeclSyntax(
            leadingTrivia: leadingTrivia,
            modifiers: DeclModifierListSyntax(arrayLiteral: .public, .static),
            name: token.with(\.trailingTrivia, .space),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax {
                    FunctionParameterSyntax(
                        firstName: "lhs",
                        type: TypeSyntax(
                            IdentifierTypeSyntax(name: .keyword(.Self))
                        )
                    )

                    FunctionParameterSyntax(
                        firstName: "rhs",
                        type: TypeSyntax(
                            IdentifierTypeSyntax(name: .keyword(.Self))
                        )
                    )
                },
                returnClause: ReturnClauseSyntax(
                    type: IdentifierTypeSyntax(name: "Bool")
                )
            ),
            bodyBuilder: {
                // lhs.wrappedValue \(token) rhs.wrappedValue
                CodeBlockItemSyntax(
                    item: .expr(
                        ExprSyntax(
                            InfixOperatorExprSyntax(
                                leftOperand: MemberAccessExprSyntax(
                                    base: ExprSyntax(DeclReferenceExprSyntax(baseName: "lhs")),
                                    name: .wrappedValue
                                ),
                                operator: BinaryOperatorExprSyntax(
                                    operator: token
                                ),
                                rightOperand: MemberAccessExprSyntax(
                                    base: ExprSyntax(DeclReferenceExprSyntax(baseName: "rhs")),
                                    name: .wrappedValue
                                )
                            )
                        )
                    )
                )
            }
        )
    }
}
