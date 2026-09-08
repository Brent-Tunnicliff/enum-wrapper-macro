// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax
import SwiftSyntaxBuilder

extension TokenSyntax {
    static let wrappedValue: TokenSyntax = "wrappedValue"
    static let wrappedValueType: TokenSyntax = "WrappedValue"
}

// MARK: wrappedValue

extension DeclReferenceExprSyntax {
    static let wrappedValue = DeclReferenceExprSyntax(baseName: .wrappedValue)
}

extension Optional where Wrapped == DeclReferenceExprSyntax {
    static var wrappedValueDeclReference: Self { .wrappedValue }
}

extension IdentifierPatternSyntax {
    static let wrappedValue = IdentifierPatternSyntax(identifier: .wrappedValue)
}

extension PatternSyntaxProtocol where Self == IdentifierPatternSyntax {
    static var wrappedValueIdentifier: IdentifierPatternSyntax { .wrappedValue }
}

// MARK: wrappedValueType

extension DeclReferenceExprSyntax {
    static let wrappedValueType = DeclReferenceExprSyntax(baseName: .wrappedValueType)
}

extension ExprSyntaxProtocol where Self == DeclReferenceExprSyntax {
    static var wrappedValueTypeDeclReference: Self { .wrappedValueType }
}

extension IdentifierTypeSyntax {
    static let wrappedValueType = IdentifierTypeSyntax(name: .wrappedValueType)
}

extension TypeSyntaxProtocol where Self == IdentifierTypeSyntax {
    static var wrappedValueIdentifierType: IdentifierTypeSyntax { .wrappedValueType }
}

extension IdentifierPatternSyntax {
    static let wrappedValueType = IdentifierPatternSyntax(identifier: .wrappedValueType)
}

extension PatternSyntaxProtocol where Self == IdentifierPatternSyntax {
    static var wrappedValueTypeIdentifier: IdentifierPatternSyntax { .wrappedValueType }
}
