// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntaxMacrosGenericTestSupport
import Testing

#if canImport(MacroModule)
    @testable import MacroModule
#endif

extension PublicWrapperMacroTests {
    @Test
    func successWithComplexEnum() {
        let allProtocols: String = {
            #if canImport(MacroModule)
                ProtocolSupportedInheritanceType.TypeName.allCases.map(\.rawValue).joined(separator: ", ")
            #else
                ""
            #endif
        }()

        let input = """
            /// Complex enum that conforms to all supported types.
            @PublicWrapper
            enum ComplexEnum: Float, \(allProtocols) {
                /// The first case.
                case one = 1.1

                /// The second case.
                ///
                /// - Warning: This is not the first case.
                case two = 2.2

                var id: Float {
                    rawValue
                }
            }
            """
        let expectedResult = """
            /// Complex enum that conforms to all supported types.
            enum ComplexEnum: Float, \(allProtocols) {
                /// The first case.
                case one = 1.1

                /// The second case.
                ///
                /// - Warning: This is not the first case.
                case two = 2.2

                var id: Float {
                    rawValue
                }
            }

            /// Complex enum that conforms to all supported types.
            public struct ComplexEnumWrapper: RawRepresentable, \(allProtocols) {
                typealias WrappedValue = ComplexEnum

                let wrappedValue: WrappedValue

                private init(wrappedValue: WrappedValue) {
                    self.wrappedValue = wrappedValue
                }


                /// The first case.
                public static let one = Self.init(wrappedValue: .one)

                /// The second case.
                ///
                /// - Warning: This is not the first case.
                public static let two = Self.init(wrappedValue: .two)

                // MARK: RawRepresentable

                public typealias RawValue = Float

                public var rawValue: RawValue {
                    wrappedValue.rawValue
                }

                public init?(rawValue: RawValue) {
                    guard let wrappedValue = WrappedValue(rawValue: rawValue) else {
                        return nil
                    }
                    self.wrappedValue = wrappedValue
                }

                // MARK: CaseIterable

                public static let allCases = WrappedValue.allCases.map(Self.init)

                // MARK: Decodable

                public init(from decoder: any Decoder) throws {
                    self.wrappedValue = try WrappedValue(from: decoder)
                }

                // MARK: Encodable

                public func encode(to encoder: any Encoder) throws {
                    try wrappedValue.encode(to: encoder)
                }

                // MARK: Comparable

                public static func < (lhs: Self, rhs: Self) -> Bool {
                    lhs.wrappedValue < rhs.wrappedValue
                }

                public static func <= (lhs: Self, rhs: Self) -> Bool {
                    lhs.wrappedValue <= rhs.wrappedValue
                }

                public static func >= (lhs: Self, rhs: Self) -> Bool {
                    lhs.wrappedValue >= rhs.wrappedValue
                }

                public static func > (lhs: Self, rhs: Self) -> Bool {
                    lhs.wrappedValue > rhs.wrappedValue
                }

                // MARK: CustomDebugStringConvertible

                public var debugDescription: String {
                    wrappedValue.debugDescription
                }

                // MARK: CustomStringConvertible

                public var description: String {
                    wrappedValue.description
                }

                // MARK: Identifiable

                public var id: Float {
                    wrappedValue.id
                }
            }
            """

        assertMacroExpansion(
            input,
            expandedSource: expectedResult,
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }

    @Test
    func successWithSimpleEnum() {
        let input = """
            @PublicWrapper
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

            public struct SimpleEnumWrapper: Equatable, Hashable, Sendable {
                typealias WrappedValue = SimpleEnum

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
            expandedSource: expectedResult,
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }

    func commentsCarryOverToWrapper() {
        let input = """
            // This comment is attached to the enum.
            @PublicWrapper
            enum EnumWithComments {
                // This comment is attached
                // to the case one.
                case one

                /*
                 This comment is attached to the case two.
                 */
                case two

                // This should apply to both.
                case three, four
            }
            """
        let expectedResult = """
            // This comment is attached to the enum.
            enum EnumWithComments {
                // This comment is attached
                // to the case one.
                case one

                /*
                 This comment is attached to the case two.
                 */
                case two

                // This should apply to both.
                case three, four
            }

            // This comment is attached to the enum.
            public struct EnumWithCommentsWrapper: Equatable, Hashable, Sendable {
                typealias WrappedValue = EnumWithComments

                let wrappedValue: WrappedValue

                private init(wrappedValue: WrappedValue) {
                    self.wrappedValue = wrappedValue
                }


                // This comment is attached
                // to the case one.
                public static let one = Self.init(wrappedValue: .one)

                /*
                 This comment is attached to the case two.
                 */
                public static let two = Self.init(wrappedValue: .two)

                // This should apply to both.
                public static let three = Self.init(wrappedValue: .three)

                // This should apply to both.
                public static let four = Self.init(wrappedValue: .four)
            }
            """

        assertMacroExpansion(
            input,
            expandedSource: expectedResult,
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }

    func documentationCarryOverToWrapper() {
        let input = """
            /// This comment is attached to the enum.
            @PublicWrapper
            enum EnumWithDocumentation {
                /// This comment is attached
                /// to the case one.
                case one

                /**
                 This comment is attached to the case two.
                 */
                case two

                /// This should apply to both.
                case three, four
            }
            """
        let expectedResult = """
            /// This comment is attached to the enum.
            enum EnumWithDocumentation {
                /// This comment is attached
                /// to the case one.
                case one

                /**
                 This comment is attached to the case two.
                 */
                case two

                /// This should apply to both.
                case three, four
            }

            /// This comment is attached to the enum.
            public struct EnumWithDocumentationWrapper: Equatable, Hashable, Sendable {
                typealias WrappedValue = EnumWithDocumentation

                let wrappedValue: WrappedValue

                private init(wrappedValue: WrappedValue) {
                    self.wrappedValue = wrappedValue
                }


                /// This comment is attached
                /// to the case one.
                public static let one = Self.init(wrappedValue: .one)

                /**
                 This comment is attached to the case two.
                 */
                public static let two = Self.init(wrappedValue: .two)

                /// This should apply to both.
                public static let three = Self.init(wrappedValue: .three)

                /// This should apply to both.
                public static let four = Self.init(wrappedValue: .four)
            }
            """

        assertMacroExpansion(
            input,
            expandedSource: expectedResult,
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }

    func attributesCarryOverToWrapper() {
        let input = """
            @PublicWrapper
            @available(iOS 26, *)
            @available(macOS 26, *)
            enum SimpleEnum {
                case value
            }
            """
        let expectedResult = """
            @available(iOS 26, *)
            @available(macOS 26, *)
            enum SimpleEnum {
                case value
            }
            @available(iOS 26, *)
            @available(macOS 26, *)
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
            expandedSource: expectedResult,
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }
}
