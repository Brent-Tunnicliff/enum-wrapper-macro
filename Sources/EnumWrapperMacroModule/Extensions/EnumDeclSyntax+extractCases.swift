// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxMacros

extension EnumDeclSyntax {
    func extractCases(context: some MacroExpansionContext) -> [EnumCaseElementSyntax] {
        var cases: [EnumCaseElementSyntax] = []

        for member in memberBlock.members {
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else {
                continue
            }

            for element in caseDecl.elements {
                guard element.parameterClause == nil else {
                    // This case has associated values, record an error and skip.
                    context.diagnose(.associatedValuesNotSupported(node: element))
                    continue
                }

                // Pass any leading trivia comments to the case elements.
                let hasNoComments = caseDecl.leadingTrivia.pieces.filter(\.isComment).isEmpty

                let leadingTrivia: Trivia
                if hasNoComments {
                    leadingTrivia = Trivia(pieces: [])
                } else {
                    leadingTrivia = Trivia(
                        pieces: caseDecl.leadingTrivia.filter { $0.isComment || $0.isNewline }
                    )
                }

                cases.append(element.with(\.leadingTrivia, leadingTrivia))
            }
        }

        return cases
    }
}

extension DiagnosticMessage {
    fileprivate static func associatedValuesNotSupported(node: some SyntaxProtocol) -> DiagnosticMessage {
        DiagnosticMessage(
            message: "Enum cases with associated values are not supported.",
            node: node,
            severity: .error
        )
    }
}
