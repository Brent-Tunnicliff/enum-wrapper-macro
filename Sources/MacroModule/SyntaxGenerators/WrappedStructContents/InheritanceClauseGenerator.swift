// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension WrapperStructGenerator.MemberBlockGenerator {
    enum InheritanceClauseGenerator {}
}

extension WrapperStructGenerator.MemberBlockGenerator.InheritanceClauseGenerator {
    /// Generates the contents of the Inheritance types.
    static func generate(inheritance: Inheritance) -> [any DeclSyntaxProtocol] {
        let rawValueResults: [any DeclSyntaxProtocol]
        if let rawValueType = inheritance.rawValue?.type {
            rawValueResults = rawValueType.generateRawValueSyntax
        } else {
            rawValueResults = []
        }

        let protocolResults = inheritance.protocols.flatMap(\.type.generateProtocolSyntax)

        return rawValueResults + protocolResults
    }
}

extension ProtocolSupportedInheritanceType {
    fileprivate var generateProtocolSyntax: [any DeclSyntaxProtocol] {
        // TODO: Add logic
        []
    }
}

extension RawValueSupportedInheritanceType {
    fileprivate var generateRawValueSyntax: [any DeclSyntaxProtocol] {
        [
            rawValueVariableSyntax,
            rawValueInitSyntax,
        ]
    }

    private var rawValueTypeSyntax: IdentifierTypeSyntax {
        IdentifierTypeSyntax(name: .identifier(rawValue))
    }

    /// Generates the rawValue property wrapper.
    ///
    /// Example:
    /// ```
    /// public var rawValue: String {
    ///     value.rawValue
    /// }
    /// ```
    private var rawValueVariableSyntax: some DeclSyntaxProtocol {
        VariableDeclSyntax(
            leadingTrivia: .inheritanceLeadingTrivia("RawRepresentable"),
            modifiers: DeclModifierListSyntax {
                .public
            },
            bindingSpecifier: .keyword(.var),
            bindings: PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: .rawValueIdentifier,
                    typeAnnotation: TypeAnnotationSyntax(type: rawValueTypeSyntax),
                    accessorBlock: AccessorBlockSyntax(
                        accessors: .getter(
                            CodeBlockItemListSyntax {
                                CodeBlockItemSyntax(
                                    item: .expr(
                                        ExprSyntax(
                                            MemberAccessExprSyntax(base: .wrappedValueDeclReference, name: .rawValue)
                                        )
                                    )
                                )
                            }
                        )
                    )
                )
            }
        )
    }

    /// Generates the rawValue initialiser wrapper.
    ///
    /// Example:
    /// ```
    /// public init?(rawValue: String) {
    ///     guard let wrappedValue = WrappedValue(rawValue: rawValue) else {
    ///         return nil
    ///     }
    ///     self.wrappedValue = wrappedValue
    /// }
    /// ```
    private var rawValueInitSyntax: some DeclSyntaxProtocol {
        InitializerDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: DeclModifierListSyntax {
                .public
            },
            optionalMark: .postfixQuestionMarkToken(),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            firstName: .rawValue,
                            type: rawValueTypeSyntax
                        )
                    }
                )
            ),
            body: CodeBlockSyntax {
                // guard let wrappedValue = WrappedValue(rawValue: rawValue) else { return nil }
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
                                                                label: .rawValue,
                                                                colon: .colonToken(),
                                                                expression: DeclReferenceExprSyntax(baseName: .rawValue)
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
                                    base: .selfDeclReference,
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
}

extension Trivia {
    static func inheritanceLeadingTrivia(_ text: String) -> Trivia {
        Trivia(pieces: [
            .newlines(2),
            .lineComment("// MARK: - \(text)"),
            .newlines(2),
        ])
    }
}
