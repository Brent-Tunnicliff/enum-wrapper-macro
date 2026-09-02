// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

#if canImport(MacroModule)
    @testable import MacroModule
    private let testMacros: [String: MacroSpec] = ["PublicWrapper": MacroSpec(type: PublicWrapperMacro.self)]
#else
    private let testMacros: [String: MacroSpec] = [:]
#endif

// TODO: Error with associated value

@Suite(.enabled(if: !testMacros.isEmpty, "Platform does not support running Macro tests"))
struct PublicWrapperMacroTests {}

// MARK: - success tests

extension PublicWrapperMacroTests {
    enum SuccessArguments: CaseIterable {
        /// Complex enum that has a raw value type and conforms to all protocols.
        case complex

        /// Simple enum with no conformances adds Sendable conformance.
        case simple

        /// We expect explicit Sendable conformance to end up with the same wrapper as `basic`.
        case simpleWithSendable

        /// We expect comments attached to enum and the cases to be included.
        case withComments

        /// We expect documentation attached to enum and the cases to be included.
        case withDocumentation
    }

    @Test(arguments: SuccessArguments.allCases)
    func success(_ argument: SuccessArguments) {
        let (input, expectedResult) = argument.values
        assertMacroExpansion(
            input,
            expandedSource: expectedResult,
            macroSpecs: testMacros,
            failureHandler: Issue.record(failure:)
        )
    }
}

extension PublicWrapperMacroTests.SuccessArguments {
    private var allProtocolsSyntax: String {
        #if canImport(MacroModule)
            ProtocolSupportedInheritanceType.TypeName.allCases.map(\.rawValue).joined(separator: ", ")
        #else
            ""
        #endif
    }

    fileprivate var values: (input: String, expectedResult: String) {
        let input: String
        let expectedResult: String
        switch self {
        case .complex:
            let allProtocols = allProtocolsSyntax
            input = """
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
            expectedResult = """
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
        case .simple:
            input = """
                @PublicWrapper
                enum SimpleEnum {
                    case one
                    case two
                }
                """
            expectedResult = """
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
        case .simpleWithSendable:
            input = """
                @PublicWrapper
                enum EnumWithSendable: Sendable {
                    case one
                    case two
                }
                """
            expectedResult = """
                enum EnumWithSendable: Sendable {
                    case one
                    case two
                }

                public struct EnumWithSendableWrapper: Sendable, Equatable, Hashable {
                    typealias WrappedValue = EnumWithSendable

                    let wrappedValue: WrappedValue

                    private init(wrappedValue: WrappedValue) {
                        self.wrappedValue = wrappedValue
                    }

                    public static let one = Self.init(wrappedValue: .one)
                    public static let two = Self.init(wrappedValue: .two)
                }
                """
        case .withComments:
            input = """
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
            expectedResult = """
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
        case .withDocumentation:
            input = """
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
            expectedResult = """
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
        }

        return (input, expectedResult)
    }
}

extension PublicWrapperMacroTests {
    struct SupportedRawValueTypeArgument: CaseIterable, CustomStringConvertible, Sendable {
        static var allCases: [PublicWrapperMacroTests.SupportedRawValueTypeArgument] {
            #if canImport(MacroModule)
                RawValueSupportedInheritanceType.allCases.map {
                    SupportedRawValueTypeArgument.init(description: $0.rawValue)
                }
            #else
                []
            #endif
        }

        let description: String
    }

    @Test(arguments: SupportedRawValueTypeArgument.allCases)
    func supported(rawValueType: SupportedRawValueTypeArgument) {
        let input = """
            @PublicWrapper
            enum Value: \(rawValueType) {
                case one
            }
            """

        // We expect wrapping RawRepresentable enum types to auto conform the struct to Equatable and Hashable too.
        let expectedResult = """
            enum Value: \(rawValueType) {
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

                public typealias RawValue = \(rawValueType)

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
