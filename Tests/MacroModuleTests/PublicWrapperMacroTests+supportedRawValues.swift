// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntaxMacrosGenericTestSupport
import Testing

#if canImport(MacroModule)
    @testable import MacroModule

    extension PublicWrapperMacroTests {
        static let supportedRawValues: [String] = RawValueSupportedInheritanceType.allCases.map(\.rawValue)

        @Test(arguments: supportedRawValues)
        func supported(rawValue: String) {
            let input = """
                @PublicWrapper
                enum Value: \(rawValue) {
                    case one
                }
                """

            // We expect wrapping RawRepresentable enum types to auto conform the struct to Equatable and Hashable too.
            let expectedResult = """
                enum Value: \(rawValue) {
                    case one
                }

                public struct ValueWrapper: RawRepresentable, Equatable, Hashable, Sendable {
                    typealias WrappedValue = Value

                    let wrappedValue: WrappedValue

                    private init(wrappedValue: WrappedValue) {
                        self.wrappedValue = wrappedValue
                    }

                    public static let one = Self.init(wrappedValue: .one)

                    // MARK: RawRepresentable

                    public typealias RawValue = \(rawValue)

                    public var rawValue: RawValue {
                        wrappedValue.rawValue
                    }

                    public init?(rawValue: RawValue) {
                        guard let wrappedValue = WrappedValue(rawValue: rawValue) else {
                            return nil
                        }
                        self.wrappedValue = wrappedValue
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
    }

#endif
