// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder

extension WrapperStructGenerator.MemberBlockGenerator.InheritanceClauseGenerator {
    /// Generates `CaseIterable` wrapper.
    ///
    /// Example:
    /// ```
    /// // MARK: CaseIterable
    ///
    /// public static let allCases = WrappedValue.allCases.map(Self.init)
    /// ```
    static let caseIterableSyntax: some DeclSyntaxProtocol =
        VariableDeclSyntax(
            leadingTrivia: .inheritanceLeadingTrivia(.caseIterable),
            modifiers: DeclModifierListSyntax(arrayLiteral: .public, .static),
            bindingSpecifier: .keyword(.let),
            bindings: PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: "allCases"),
                    initializer: InitializerClauseSyntax(
                        value: FunctionCallExprSyntax(
                            calledExpression: MemberAccessExprSyntax(
                                base: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax.wrappedValueType,
                                    name: "allCases"
                                ),
                                name: "map"
                            ),
                            leftParen: .leftParenToken(),
                            arguments: LabeledExprListSyntax {
                                LabeledExprSyntax(
                                    expression: MemberAccessExprSyntax(
                                        base: DeclReferenceExprSyntax(baseName: .keyword(.Self)),
                                        name: .keyword(.`init`)
                                    )
                                )
                            },
                            rightParen: .rightParenToken()
                        )
                    )
                )
            }
        )
}
