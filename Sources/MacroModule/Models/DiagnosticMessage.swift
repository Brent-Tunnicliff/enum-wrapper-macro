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

    init(
        diagnosticID: String = #function,
        message: String,
        node: some SyntaxProtocol,
        severity: Severity
    ) {
        self.diagnosticID = MessageID(domain: "EnumWrapperMacro", id: diagnosticID.description)
        self.message = message
        self.node = node
        self.severity = severity.diagnosticSeverity
    }

    func generateDiagnostic() -> Diagnostic {
        Diagnostic(node: node, message: self)
    }
}

extension DiagnosticMessage {
    // Wrapper of DiagnosticSeverity so I don't need to import SwiftDiagnostics in places that use these extensions.
    enum Severity {
        case error
        case warning
        case note
        case remark

        fileprivate var diagnosticSeverity: DiagnosticSeverity {
            switch self {
            case .error: .error
            case .warning: .warning
            case .note: .note
            case .remark: .remark
            }
        }
    }
}
