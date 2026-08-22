// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

#if DEBUG

    import SwiftDiagnostics
    import SwiftSyntax
    import SwiftSyntaxMacros

    @available(*, deprecated, message: "Only to be used for debug purposes while working on the package.")
    extension MacroExpansionContext {
        /// Helper diagnostic message to provide quick feedback during development.
        ///
        /// Only present in Debug configurations.
        func debugDiagnose(
            node: some SyntaxProtocol,
            message: String,
            id: String,
            severity: DiagnosticSeverity = .warning
        ) {
            self.diagnose(
                Diagnostic(
                    node: node,
                    message: DebugDiagnosticMessage(message: message, id: id, severity: severity)
                )
            )
        }
    }

    private struct DebugDiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
        let diagnosticID: MessageID
        let message: String
        let severity: DiagnosticSeverity

        init(message: String, id: String, severity: DiagnosticSeverity) {
            self.message = message
            self.diagnosticID = MessageID(domain: "DebugDiagnosticMessage", id: id)
            self.severity = severity
        }
    }

#endif
