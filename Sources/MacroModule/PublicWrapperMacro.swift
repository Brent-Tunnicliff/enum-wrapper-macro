// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

public import SwiftSyntax
public import SwiftSyntaxMacros
import SwiftSyntaxBuilder

/*
 TODO: Test ideas
    - Error with associated value
 */

public struct PublicWrapperMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // If the declaration is not an enum, then raise a diagnostic error and don't generate any code.
        guard let enumDeclaration = enumDeclaration(from: declaration) else {
            context.diagnose(.onlyEnumsSupported(node: declaration))
            return []
        }

        return [try WrapperStructGenerator.generate(declaration: enumDeclaration, context: context)]
    }

    private static func enumDeclaration(from declaration: some DeclSyntaxProtocol) -> EnumDeclSyntax? {
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
            return nil
        }

        return enumDeclaration
    }
}
