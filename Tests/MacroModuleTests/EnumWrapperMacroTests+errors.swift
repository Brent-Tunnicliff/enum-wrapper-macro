// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntaxMacrosGenericTestSupport
import Testing

extension EnumWrapperMacroTests {
    @Test(arguments: ["actor", "class", "struct"])
    func wrappingNonEnumTypeNotSupported(type: String) {
        assertMacroExpansion(
            "@EnumWrapper \(type) Value {}",
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
            "@EnumWrapper func doTheThing() {}",
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
            "@EnumWrapper var isEnabled: Bool",
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

            @EnumWrapper typealias EnumValue = Value
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
            @EnumWrapper
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
            @EnumWrapper
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

    // We do not support indirect cases. It is just caught by the associated values flow.
    @Test
    func indirectCasesNotSupported() {
        let input = """
            @EnumWrapper
            enum IndirectEnum {
                case one
                case two
                indirect case addition(IndirectEnum, IndirectEnum)
            }
            """
        let expandedSource = """
            enum IndirectEnum {
                case one
                case two
                indirect case addition(IndirectEnum, IndirectEnum)
            }

            public struct IndirectEnumWrapper: Equatable, Hashable, Sendable {
                typealias WrappedValue = IndirectEnum

                let wrappedValue: WrappedValue

                private init(wrappedValue: WrappedValue) {
                    self.wrappedValue = wrappedValue
                }

                public static let one = Self.init(wrappedValue: .one)
                public static let two = Self.init(wrappedValue: .two)
            }
            """

        assertMacroExpansion(
            input,
            expandedSource: expandedSource,
            diagnostics: [
                DiagnosticSpec(
                    message: "Enum cases with associated values are not supported.",
                    line: 5,
                    column: 19
                )
            ],
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }

    @Test
    func accessArgumentNotSupported() {
        let input = """
            @EnumWrapper(access: "invalid")
            enum SimpleEnum {
                case value
            }
            """
        let expandedSource = """
            enum SimpleEnum {
                case value
            }

            public struct SimpleEnumWrapper: Equatable, Hashable, Sendable {
                typealias WrappedValue = SimpleEnum

                let wrappedValue: WrappedValue

                private init(wrappedValue: WrappedValue) {
                    self.wrappedValue = wrappedValue
                }

                public static let value = Self.init(wrappedValue: .value)
            }
            """

        assertMacroExpansion(
            input,
            expandedSource: expandedSource,
            diagnostics: [
                DiagnosticSpec(
                    message: "'access' does not support value 'invalid'. "
                        + "supported value are 'public', 'package', 'internal', 'fileprivate', 'private'.",
                    line: 1,
                    column: 1
                )
            ],
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }

    @Test
    func accessArgumentNotLiteral() {
        let input = """
            let access: StaticString = "package"
            @EnumWrapper(access: access)
            enum SimpleEnum {
                case value
            }
            """
        let expandedSource = """
            let access: StaticString = "package"
            enum SimpleEnum {
                case value
            }

            public struct SimpleEnumWrapper: Equatable, Hashable, Sendable {
                typealias WrappedValue = SimpleEnum

                let wrappedValue: WrappedValue

                private init(wrappedValue: WrappedValue) {
                    self.wrappedValue = wrappedValue
                }

                public static let value = Self.init(wrappedValue: .value)
            }
            """

        assertMacroExpansion(
            input,
            expandedSource: expandedSource,
            diagnostics: [
                DiagnosticSpec(
                    message: "'access' is not a literal expression, passing in a runtime value is not supported.",
                    line: 2,
                    column: 1
                )
            ],
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }
}
