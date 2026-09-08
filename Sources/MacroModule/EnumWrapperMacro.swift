// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

public import SwiftSyntax
import SwiftSyntaxBuilder
public import SwiftSyntaxMacros

/// Wrapper for generating a public struct to wrap an enum.
public struct EnumWrapperMacro: PeerMacro {
    /// Expand a EnumWrapper macro.
    ///
    /// The macro expansion can introduce "peer" declarations that sit alongside the given declaration.
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        // If the declaration is not an enum, then raise a diagnostic error and don't generate any code.
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
            context.diagnose(.onlyEnumsSupported(node: declaration))
            return []
        }

        return [WrapperStructGenerator.generate(declaration: enumDeclaration, context: context)]
    }
}

extension DiagnosticMessage {
    fileprivate static func onlyEnumsSupported(node: some SyntaxProtocol) -> DiagnosticMessage {
        DiagnosticMessage(
            message: "Only enum types are supported.",
            node: node,
            severity: .error
        )
    }
}
