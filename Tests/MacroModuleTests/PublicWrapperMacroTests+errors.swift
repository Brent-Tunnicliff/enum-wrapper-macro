// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntaxMacrosGenericTestSupport
import Testing

extension PublicWrapperMacroTests {
    @Test(arguments: ["actor", "class", "struct"])
    func wrappingNonEnumTypeNotSupported(type: String) {
        assertMacroExpansion(
            "@PublicWrapper \(type) Value {}",
            expandedSource: "\(type) Value {}",
            diagnostics: [
                DiagnosticSpec(
                    message: "Only enum types are supported.",
                    line: 1,
                    column: 1
                )
            ],
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }

    @Test
    func wrappingFunctionNotSupported() {
        assertMacroExpansion(
            "@PublicWrapper func doTheThing() {}",
            expandedSource: "func doTheThing() {}",
            diagnostics: [
                DiagnosticSpec(
                    message: "Only enum types are supported.",
                    line: 1,
                    column: 1
                )
            ],
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }

    @Test
    func wrappingVariablesNotSupported() {
        assertMacroExpansion(
            "@PublicWrapper var isEnabled: Bool",
            expandedSource: "var isEnabled: Bool",
            diagnostics: [
                DiagnosticSpec(
                    message: "Only enum types are supported.",
                    line: 1,
                    column: 1
                )
            ],
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }

    /// We only support the macro attached to the enum directly, not cases of a typealias pointing to an enum.
    @Test
    func wrappingTypealiasNotSupported() {
        assertMacroExpansion(
            """
            enum Value {
                case one
            }

            @PublicWrapper typealias EnumValue = Value
            """,
            expandedSource: """
                enum Value {
                    case one
                }

                typealias EnumValue = Value
                """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Only enum types are supported.",
                    line: 5,
                    column: 1
                )
            ],
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }

    // We do not support associated values as that greatly complicates other mapping logic.
    @Test
    func associatedValuesNotSupported() {
        let input = """
            @PublicWrapper
            enum Value {
                case one
                case two(String)
                case three
            }
            """
        let expandedSource = """
            enum Value {
                case one
                case two(String)
                case three
            }

            public struct ValueWrapper: Equatable, Hashable, Sendable {
                typealias WrappedValue = Value

                let wrappedValue: WrappedValue

                private init(wrappedValue: WrappedValue) {
                    self.wrappedValue = wrappedValue
                }

                public static let one = Self.init(wrappedValue: .one)
                public static let three = Self.init(wrappedValue: .three)
            }
            """

        assertMacroExpansion(
            input,
            expandedSource: expandedSource,
            diagnostics: [
                DiagnosticSpec(
                    message: "Enum cases with associated values are not supported.",
                    line: 4,
                    column: 10
                )
            ],
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }

    // While this will be a compile error anyway, we still populate our own specific error message too.
    @Test
    func multipleRawValuesNotSupported() {
        let input = """
            @PublicWrapper
            enum Value: String, Int {
                case one
            }
            """
        let expandedSource = """
            enum Value: String, Int {
                case one
            }

            public struct ValueWrapper: Equatable, Hashable, Sendable {
                typealias WrappedValue = Value

                let wrappedValue: WrappedValue

                private init(wrappedValue: WrappedValue) {
                    self.wrappedValue = wrappedValue
                }

                public static let one = Self.init(wrappedValue: .one)
            }
            """

        assertMacroExpansion(
            input,
            expandedSource: expandedSource,
            diagnostics: [
                DiagnosticSpec(
                    message: "A maximum of 1 raw value type is supported.",
                    line: 1,
                    column: 1
                )
            ],
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }
}
