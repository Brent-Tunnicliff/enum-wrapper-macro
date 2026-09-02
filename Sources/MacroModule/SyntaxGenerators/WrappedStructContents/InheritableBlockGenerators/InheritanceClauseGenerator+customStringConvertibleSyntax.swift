// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder

extension WrapperStructGenerator.MemberBlockGenerator.InheritanceClauseGenerator {
    /// Generates `CustomStringConvertible` wrapper.
    ///
    /// Example:
    /// ```
    /// // MARK: CustomStringConvertible
    ///
    /// public var description: String {
    ///     wrappedValue.description
    /// }
    /// ```
    static let customStringConvertibleSyntax: some DeclSyntaxProtocol =
        VariableDeclSyntax(
            leadingTrivia: .inheritanceLeadingTrivia(.customStringConvertible),
            modifiers: DeclModifierListSyntax(arrayLiteral: .public),
            bindingSpecifier: .keyword(.var),
            bindings: PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: "description"),
                    typeAnnotation: TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: "String")),
                    accessorBlock: AccessorBlockSyntax(
                        accessors: .getter(
                            CodeBlockItemListSyntax {
                                CodeBlockItemSyntax(
                                    item: .expr(
                                        ExprSyntax(
                                            MemberAccessExprSyntax(
                                                base: .wrappedValueDeclReference,
                                                name: "description"
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
