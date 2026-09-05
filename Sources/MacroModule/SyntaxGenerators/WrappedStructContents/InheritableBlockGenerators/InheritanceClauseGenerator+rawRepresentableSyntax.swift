// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder

extension WrapperStructGenerator.MemberBlockGenerator.InheritanceClauseGenerator {
    /// Generates the rawValue conformance syntax.
    ///
    /// Example:
    /// ```
    /// // MARK: RawRepresentable
    ///
    /// public typealias RawValue = String
    ///
    /// public var rawValue: RawValue {
    ///     wrappedValue.rawValue
    /// }
    ///
    /// public init?(rawValue: RawValue) {
    ///     guard let wrappedValue = WrappedValue(rawValue: rawValue) else {
    ///         return nil
    ///     }
    ///     self.wrappedValue = wrappedValue
    /// }
    /// ```
    static func rawRepresentableSyntax(for rawValueType: RawValueSupportedInheritanceType) -> [any DeclSyntaxProtocol] {
        [
            typealiasSyntax(for: rawValueType),
            variableSyntax,
            rawValueInitSyntax,
        ]
    }

    /// Generates the RawValue typealias.
    ///
    /// Example:
    /// `public typealias RawValue = String`
    private static func typealiasSyntax(for rawValueType: RawValueSupportedInheritanceType) -> some DeclSyntaxProtocol {
        TypeAliasDeclSyntax(
            leadingTrivia: .inheritanceLeadingTrivia("RawRepresentable"),
            modifiers: DeclModifierListSyntax(arrayLiteral: .public),
            name: "RawValue",
            initializer: TypeInitializerClauseSyntax(
                value: IdentifierTypeSyntax(name: .identifier(rawValueType.rawValue))
            )
        )
    }

    /// Generates the rawValue property wrapper.
    ///
    /// Example:
    /// ```
    /// public var rawValue: RawValue {
    ///     wrappedValue.rawValue
    /// }
    /// ```
    private static let variableSyntax: some DeclSyntaxProtocol =
        VariableDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: DeclModifierListSyntax(arrayLiteral: .public),
            bindingSpecifier: .keyword(.var),
            bindings: PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: "rawValue"),
                    typeAnnotation: TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: "RawValue")),
                    accessorBlock: AccessorBlockSyntax(
                        accessors: .getter(
                            CodeBlockItemListSyntax {
                                CodeBlockItemSyntax(
                                    item: .expr(
                                        ExprSyntax(
                                            MemberAccessExprSyntax(base: .wrappedValueDeclReference, name: "rawValue")
                                        )
                                    )
                                )
                            }
                        )
                    )
                )
            }
        )

    /// Generates the rawValue initialiser wrapper.
    ///
    /// Example:
    /// ```
    /// public init?(rawValue: RawValue) {
    ///     guard let wrappedValue = WrappedValue(rawValue: rawValue) else {
    ///         return nil
    ///     }
    ///     self.wrappedValue = wrappedValue
    /// }
    /// ```
    private static let rawValueInitSyntax: some DeclSyntaxProtocol =
        InitializerDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: DeclModifierListSyntax(arrayLiteral: .public),
            optionalMark: .postfixQuestionMarkToken(),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            firstName: "rawValue",
                            type: IdentifierTypeSyntax(name: "RawValue")
                        )
                    }
                )
            ),
            body: CodeBlockSyntax {
                // guard let wrappedValue = WrappedValue(rawValue: rawValue) else {
                //     return nil
                // }
                CodeBlockItemSyntax(
                    item: .stmt(
                        StmtSyntax(
                            GuardStmtSyntax(
                                conditions: ConditionElementListSyntax {
                                    ConditionElementSyntax(
                                        condition: .optionalBinding(
                                            OptionalBindingConditionSyntax(
                                                bindingSpecifier: .keyword(.let),
                                                pattern: .wrappedValueIdentifier,
                                                initializer: InitializerClauseSyntax(
                                                    value: FunctionCallExprSyntax(
                                                        calledExpression: .wrappedValueTypeDeclReference,
                                                        leftParen: .leftParenToken(),
                                                        arguments: LabeledExprListSyntax {
                                                            LabeledExprSyntax(
                                                                label: "rawValue",
                                                                colon: .colonToken(),
                                                                expression: DeclReferenceExprSyntax(
                                                                    baseName: "rawValue"
                                                                )
                                                            )
                                                        },
                                                        rightParen: .rightParenToken()
                                                    )
                                                )
                                            )
                                        )
                                    )
                                },
                                body: CodeBlockSyntax {
                                    CodeBlockItemSyntax(
                                        item: .stmt(
                                            StmtSyntax(
                                                ReturnStmtSyntax(
                                                    expression: NilLiteralExprSyntax()
                                                )
                                            )
                                        )
                                    )
                                }
                            )
                        )
                    )
                )

                // self.wrappedValue = wrappedValue
                CodeBlockItemSyntax(
                    item: .expr(
                        ExprSyntax(
                            SequenceExprSyntax {
                                MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(baseName: .keyword(.self)),
                                    declName: .wrappedValue
                                )

                                AssignmentExprSyntax()

                                DeclReferenceExprSyntax.wrappedValue
                            }
                        )
                    )
                )
            }
        )
}
