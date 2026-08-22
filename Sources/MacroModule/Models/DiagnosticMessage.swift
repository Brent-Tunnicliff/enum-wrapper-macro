// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

extension MacroExpansionContext {
    func diagnose(_ message: DiagnosticMessage) {
        self.diagnose(message.generateDiagnostic())
    }
}

struct DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    let diagnosticID: MessageID
    let message: String
    let severity: DiagnosticSeverity

    private let node: any SyntaxProtocol

    private init(
        diagnosticID: String = #function,
        message: String,
        node: some SyntaxProtocol,
        severity: DiagnosticSeverity
    ) {
        self.diagnosticID = MessageID(domain: "PublicWrapperMacro", id: diagnosticID.description)
        self.message = message
        self.node = node
        self.severity = severity
    }

    func generateDiagnostic() -> Diagnostic {
        Diagnostic(node: node, message: self)
    }
}

extension DiagnosticMessage {
    static func associatedValuesNotSupported(node: some SyntaxProtocol) -> DiagnosticMessage {
        DiagnosticMessage(
            message: "Enum cases with associated values are not supported.",
            node: node,
            severity: .error
        )
    }

    static func onlyEnumsSupported(node: some SyntaxProtocol) -> DiagnosticMessage {
        DiagnosticMessage(
            message: "Only enum types are supported.",
            node: node,
            severity: .error
        )
    }
}
