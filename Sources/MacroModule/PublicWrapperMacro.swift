// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftDiagnostics
public import SwiftSyntax
public import SwiftSyntaxMacros
import SwiftSyntaxBuilder

/*
 TODO: Test ideas
    - Error with associated value
 */

public struct PublicWrapperMacro {}

// MARK: - PeerMacro

extension PublicWrapperMacro: PeerMacro {
    // MARK: - Properties

    private static let variableName: TokenSyntax = .identifier("value")
    private static let variableNameSyntax = IdentifierPatternSyntax(identifier: variableName)
    private static let variableReferenceSyntax = DeclReferenceExprSyntax(baseName: variableName)
    private static let wrapperNameSuffix = "Wrapper"

    // MARK: - Syntax

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDeclaration = enumDeclaration(from: declaration) else {
            context.diagnose(
                Diagnostic.init(
                    node: declaration,
                    message: DiagnosticMessage.onlyEnumsSupported
                )
            )
            return []
        }

        return [
            DeclSyntax(wrapperStructDeclaration(of: enumDeclaration, in: context))
        ]
    }

    // Example:
    //
    // /// Any documentation from the wrapped enum.
    // public struct <ENUM_NAME>Wrapper: Sendable, <ENUM_INHERITANCES> {
    //     let value: <ENUM_NAME>
    //
    //     private init(value: <ENUM_NAME>) {
    //         self.value = value
    //     }
    //
    //     public static let <ENUM_CASE> = <ENUM_NAME>Wrapper(value: .<ENUM_CASE>)
    //
    //     // Any inheritable conformances that just call `value`.
    // }
    private static func wrapperStructDeclaration(
        of declaration: EnumDeclSyntax,
        in context: some MacroExpansionContext
    ) -> StructDeclSyntax {
        let structName = TokenSyntax.identifier(structName(from: declaration))
        let cases = cases(of: declaration, in: context)

        return StructDeclSyntax(
            leadingTrivia: Trivia(pieces: declaration.leadingTrivia.commentPieces),
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.public))
            },
            name: structName,
            inheritanceClause: declaration.inheritanceClauseWithSendable,
            memberBlock: wrapperStructMemberBlockSyntax(
                declaration: declaration,
                structName: structName,
                cases: cases
            )
        )
    }

    private static func wrapperStructMemberBlockSyntax(
        declaration: EnumDeclSyntax,
        structName: TokenSyntax,
        cases: [EnumCaseElementSyntax]
    ) -> MemberBlockSyntax {
        let enumTypeSyntax = IdentifierTypeSyntax(name: declaration.name)

        return MemberBlockSyntax(
            leadingTrivia: declaration.memberBlock.leadingTrivia,
            members: MemberBlockItemListSyntax {
                wrapperStructVariableSyntax(enumTypeSyntax: enumTypeSyntax)

                wrapperStructInitSyntax(enumTypeSyntax: enumTypeSyntax)

                wrapperStructCaseConstants(structName: structName, cases: cases)
            },
            trailingTrivia: declaration.memberBlock.trailingTrivia
        )
    }

    // Example:
    //
    // `let value: <ENUM_NAME>`
    private static func wrapperStructVariableSyntax(
        enumTypeSyntax: some TypeSyntaxProtocol
    ) -> some DeclSyntaxProtocol {
        VariableDeclSyntax(
            .let,
            name: PatternSyntax(variableNameSyntax),
            type: TypeAnnotationSyntax(type: enumTypeSyntax)
        )
    }

    // Example:
    //
    // private init(value: <ENUM_NAME>) {
    //     self.value = value
    // }
    private static func wrapperStructInitSyntax(
        enumTypeSyntax: some TypeSyntaxProtocol
    ) -> some DeclSyntaxProtocol {
        InitializerDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.private))
            },
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            firstName: variableName,
                            type: enumTypeSyntax
                        )
                    }
                )
            ),
            body: CodeBlockSyntax {
                CodeBlockItemSyntax(
                    item: .expr(
                        ExprSyntax(
                            SequenceExprSyntax(
                                elements: ExprListSyntax {
                                    MemberAccessExprSyntax(
                                        base: DeclReferenceExprSyntax(baseName: .keyword(.`self`)),
                                        declName: variableReferenceSyntax
                                    )

                                    AssignmentExprSyntax()

                                    variableReferenceSyntax
                                }
                            )
                        )
                    )
                )
            }
        )
    }

    // Example:
    //
    // public static let <ENUM_CASE> = <ENUM_NAME>Wrapper(value: .<ENUM_CASE>)
    private static func wrapperStructCaseConstants(
        structName: TokenSyntax,
        cases: [EnumCaseElementSyntax]
    ) -> [some DeclSyntaxProtocol] {
        cases.map { caseSyntax in
            VariableDeclSyntax(
                modifiers: DeclModifierListSyntax {
                    DeclModifierSyntax(name: .keyword(.public))
                    DeclModifierSyntax(name: .keyword(.static))
                },
                .let,
                name: PatternSyntax(stringLiteral: caseSyntax.name.text),
                initializer: InitializerClauseSyntax(
                    value: ExprSyntax("\(structName)(\(variableNameSyntax): .\(caseSyntax.name))")
                )
    //            type: TypeAnnotationSyntax(type: enumTypeSyntax)
            )
        }
    }

    private static func cases(
        of declaration: EnumDeclSyntax,
        in context: some MacroExpansionContext
    ) -> [EnumCaseElementSyntax] {
        var cases: [EnumCaseElementSyntax] = []

        for member in declaration.memberBlock.members {
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else {
                continue
            }

            for element in caseDecl.elements {
                guard element.parameterClause == nil else {
                    // This case has associated values, record an error and skip.
                    context.diagnose(
                        Diagnostic.init(
                            node: element,
                            message: DiagnosticMessage.associatedValuesNotSupported
                        )
                    )
                    continue
                }

                cases.append(element)
            }
        }

        return cases
    }

    // MARK: - Private Helpers

    private static func enumDeclaration(from declaration: some DeclSyntaxProtocol) -> EnumDeclSyntax? {
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
            return nil
        }

        return enumDeclaration
    }

    private static func enumName(from declaration: EnumDeclSyntax) -> String {
        declaration.name.text
    }

    private static func structName(from declaration: EnumDeclSyntax) -> String {
        "\(enumName(from: declaration))\(wrapperNameSuffix)"
    }

//    private static func cases(
//        of declaration: EnumDeclSyntax,
//        in context: some MacroExpansionContext
//    ) throws -> [EnumCaseElementSyntax] {
//        var cases: [EnumCaseElementSyntax] = []
//
//        for member in declaration.memberBlock.members {
//            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else {
//                continue
//            }
//
//            for element in caseDecl.elements {
//                guard element.parameterClause == nil else {
//                    // This case has associated values, record an error and skip.
//                    context.diagnose(
//                        Diagnostic.init(
//                            node: element,
//                            message: AssociatedValuesNotSupportedMessage()
//                        )
//                    )
//                    continue
//                }
//
//                cases.append(element)
//            }
//        }
//
//        return cases
//    }

//    private static func baseTypeSyntax(enumName: String, structName: String) -> DeclSyntax {
//        """
//        public struct \(raw: structName): Sendable {
//            let value: \(raw: enumName)
//
//            init(_ value: \(raw: enumName)) {
//                self.value = value
//            }
//        }
//        """
//    }

//    private static func casesExtensionSyntax(structName: String, enumCases: [EnumCaseElementSyntax]) -> DeclSyntax {
//        let generatedCases = enumCases.map { element in
//            // Combine any documentation with the actual declaration
//            let caseValues = documentation(from: element) + [
//                "public static let \(element.name) = \(structName)(.\(element.name))"
//            ]
//
//            return caseValues.joined(separator: "\n")
//        }
//        .joined(separator: "\n\n\t")
//
//        return """
//            extension \(raw: structName) {
//                \(raw: generatedCases)
//            }
//            """
//    }
}

// MARK: - External Helpers

private enum DiagnosticMessage: String {
    case associatedValuesNotSupported
    case onlyEnumsSupported
}

extension DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    var message: String {
        switch self {
        case .associatedValuesNotSupported:
            "Enum cases with associated values are not supported."
        case .onlyEnumsSupported:
            "Only enum types are supported."
        }
    }

    var diagnosticID: MessageID {
        return MessageID(
            domain: "PublicWrapperMacro",
            id: rawValue
        )
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .associatedValuesNotSupported, .onlyEnumsSupported: .error
        }
    }
}

extension Trivia {
    /// Returns trivia pieces filtered to only include comments and documentation.
    fileprivate var commentPieces: [TriviaPiece] {
        pieces.filter(\.isComment)
    }
}

extension EnumDeclSyntax {
    /// Injects Sendable inheritance if missing.
    fileprivate var inheritanceClauseWithSendable: InheritanceClauseSyntax {
        guard let inheritanceClause else {
            return InheritanceClauseSyntax(
                inheritedTypes: InheritedTypeListSyntax {
                    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .keyword(.Sendable)) )
                }
            )
        }

        var containsSendable = false
        for inheritedType in inheritanceClause.inheritedTypes where inheritedType.isSendable {
            containsSendable = true
        }

        // If sendable exists no need to inject it
        guard !containsSendable else {
            return inheritanceClause
        }

        return InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                inheritanceClause.inheritedTypes

                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .keyword(.Sendable)) )
            }
        )
    }
}

extension InheritedTypeSyntax {
    fileprivate var isSendable: Bool {
        IdentifierTypeSyntax(self)?.name == .keyword(.Sendable)
    }
}
