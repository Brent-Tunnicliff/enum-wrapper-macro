// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntax

extension DeclReferenceExprSyntax {
    static let `self` = DeclReferenceExprSyntax(baseName: .keyword(.`self`))
}

extension ExprSyntaxProtocol where Self == DeclReferenceExprSyntax {
    static var selfDeclReference: Self { .`self` }
}

extension Optional where Wrapped == DeclReferenceExprSyntax {
    static var selfDeclReference: Self { Wrapped.selfDeclReference }
}
