// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder

extension WrapperStructGenerator.MemberBlockGenerator.InheritanceClauseGenerator {
    /// Generates the `Identifiable` conformance syntax.
    ///
    /// Example:
    /// ```
    /// // MARK: Identifiable
    ///
    /// public var id: String {
    ///     wrappedValue.id
    /// }
    /// ```
    static func identifiableSyntax(for supportedType: String) -> some DeclSyntaxProtocol {
        VariableDeclSyntax(
            leadingTrivia: .inheritanceLeadingTrivia(.identifiable),
            modifiers: DeclModifierListSyntax(arrayLiteral: .public),
            bindingSpecifier: .keyword(.var),
            bindings: PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: "id"),
                    typeAnnotation: TypeAnnotationSyntax(
                        type: IdentifierTypeSyntax(name: .identifier(supportedType))
                    ),
                    accessorBlock: AccessorBlockSyntax(
                        accessors: .getter(
                            CodeBlockItemListSyntax {
                                CodeBlockItemSyntax(
                                    item: .expr(
                                        ExprSyntax(
                                            MemberAccessExprSyntax(
                                                base: .wrappedValueDeclReference,
                                                name: "id"
                                            )
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
}
