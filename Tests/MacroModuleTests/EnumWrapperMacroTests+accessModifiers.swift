// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntaxMacrosGenericTestSupport
import Testing

extension EnumWrapperMacroTests {
    static let accessModifierArguments = [
        "public",
        "internal",
        "package",
        "fileprivate",
        "private",
    ]

    @Test(arguments: accessModifierArguments)
    func wrappedValueMatches(accessModifier: String) {
        let input = """
            @EnumWrapper
            \(accessModifier) enum SimpleEnum {
                case one
                case two
            }
            """
        let expectedResult = """
            \(accessModifier) enum SimpleEnum {
                case one
                case two
            }

            public struct SimpleEnumWrapper: Equatable, Hashable, Sendable {
                \(accessModifier) typealias WrappedValue = SimpleEnum

                \(accessModifier) let wrappedValue: WrappedValue

                private init(wrappedValue: WrappedValue) {
                    self.wrappedValue = wrappedValue
                }

                public static let one = Self.init(wrappedValue: .one)
                public static let two = Self.init(wrappedValue: .two)
            }
            """
        assertMacroExpansion(
            input,
            expandedSource: expectedResult,
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }

    @Test(arguments: accessModifierArguments)
    func definingWrapperAccessIsAppliedAsExpected(accessModifier: String) {
        let input = """
            @EnumWrapper(access: "\(accessModifier)")
            enum SimpleEnum {
                case one
                case two
            }
            """
        let expectedResult = """
            enum SimpleEnum {
                case one
                case two
            }

            \(accessModifier) struct SimpleEnumWrapper: Equatable, Hashable, Sendable {
                typealias WrappedValue = SimpleEnum

                let wrappedValue: WrappedValue

                private init(wrappedValue: WrappedValue) {
                    self.wrappedValue = wrappedValue
                }

                \(accessModifier) static let one = Self.init(wrappedValue: .one)
                \(accessModifier) static let two = Self.init(wrappedValue: .two)
            }
            """
        assertMacroExpansion(
            input,
            expandedSource: expectedResult,
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }
}
