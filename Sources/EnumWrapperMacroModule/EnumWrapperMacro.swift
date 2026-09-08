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

        return [
            WrapperStructGenerator.generate(
                declaration: enumDeclaration,
                context: context,
                accessLevel: extractAccessLevel(node: node, context: context)
            )
        ]
    }

    private static func extractAccessLevel(
        node: AttributeSyntax,
        context: some MacroExpansionContext
    ) -> TokenSyntax {
        // If none declared then return as public.
        guard let argument = node.arguments?.as(LabeledExprListSyntax.self)?.first?.expression else {
            return .defaultAccess
        }

        guard
            let literal = argument.as(StringLiteralExprSyntax.self),
            case .stringSegment(let segment) = literal.segments.first
        else {
            context.diagnose(.accessNotLiteral(node: node))
            return .defaultAccess
        }

        let accessLevelArgumentValue = segment.content.trimmed.text

        guard let supportedAccessValue = SupportedAccess(rawValue: accessLevelArgumentValue) else {
            context.diagnose(
                .accessNotSupported(node: node, input: accessLevelArgumentValue)
            )
            return .defaultAccess
        }

        return supportedAccessValue.token
    }
}

private enum SupportedAccess: String, CaseIterable {
    case `public` = "public"
    case `package` = "package"
    case `internal` = "internal"
    case `fileprivate` = "fileprivate"
    case `private` = "private"

    var token: TokenSyntax {
        switch self {
        case .public: .keyword(.public)
        case .package: .keyword(.package)
        case .internal: .keyword(.internal)
        case .fileprivate: .keyword(.fileprivate)
        case .private: .keyword(.private)
        }
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

    fileprivate static func accessNotLiteral(node: some SyntaxProtocol) -> DiagnosticMessage {
        DiagnosticMessage(
            message: "'access' is not a literal expression, passing in a runtime value is not supported.",
            node: node,
            severity: .error
        )
    }

    fileprivate static func accessNotSupported(
        node: some SyntaxProtocol,
        input: String
    ) -> DiagnosticMessage {
        DiagnosticMessage(
            message: """
                'access' does not support value '\(input)'. \
                Supported value are \(SupportedAccess.allCases.map { "'\($0.rawValue)'" }.joined(separator: ", ")).
                """,
            node: node,
            severity: .error
        )
    }
}

extension TokenSyntax {
    fileprivate static let defaultAccess: TokenSyntax = SupportedAccess.public.token
}
