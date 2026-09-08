// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder

extension WrapperStructGenerator.MemberBlockGenerator.InheritanceClauseGenerator {
    /// Generates `CustomDebugStringConvertible` wrapper.
    ///
    /// Example:
    /// ```
    /// // MARK: CustomDebugStringConvertible
    ///
    /// public var debugDescription: String {
    ///     wrappedValue.debugDescription
    /// }
    /// ```
    static let customDebugStringConvertibleSyntax: some DeclSyntaxProtocol =
        VariableDeclSyntax(
            leadingTrivia: .inheritanceLeadingTrivia(.customDebugStringConvertible),
            modifiers: DeclModifierListSyntax(arrayLiteral: .public),
            bindingSpecifier: .keyword(.var),
            bindings: PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: "debugDescription"),
                    typeAnnotation: TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: "String")),
                    accessorBlock: AccessorBlockSyntax(
                        accessors: .getter(
                            CodeBlockItemListSyntax {
                                CodeBlockItemSyntax(
                                    item: .expr(
                                        ExprSyntax(
                                            MemberAccessExprSyntax(
                                                base: .wrappedValueDeclReference,
                                                name: "debugDescription"
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
