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

#if canImport(MacroModule)

    // MARK: SupportedRawValueTypeArgument

    extension PublicWrapperMacroTests {
        @Test(arguments: RawValueSupportedInheritanceType.allCases)
        func supported(rawValueType: RawValueSupportedInheritanceType) {
            let rawValue = rawValueType.rawValue
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

    // MARK: ProtocolSupportedInheritanceType

    extension PublicWrapperMacroTests {
        static let identifiableArguments: [ProtocolSupportedInheritanceType] = {
            let rawValueTypes: [SupportedIdentifiableType] = RawValueSupportedInheritanceType.allCases
                .map { SupportedIdentifiableType.rawValue($0) }
            let supportedTypes = rawValueTypes + [.uuid, .custom(name: "CustomIdentifiable")]
            return supportedTypes.map { .identifiable($0) }
        }()

        static let supportedProtocolTypeArguments: [ProtocolSupportedInheritanceType] = {
            ProtocolSupportedInheritanceType.TypeName
                .allCases
                .flatMap { typeName -> [ProtocolSupportedInheritanceType] in
                    switch typeName {
                    case .caseIterable: [.caseIterable]
                    case .codable: [.codable]
                    case .comparable: [.comparable]
                    case .customDebugStringConvertible: [.customDebugStringConvertible]
                    case .customStringConvertible: [.customStringConvertible]
                    case .decodable: [.decodable]
                    case .encodable: [.encodable]
                    case .equatable: [.equatable]
                    case .hashable: [.hashable]
                    case .identifiable: identifiableArguments
                    case .sendable: [.sendable]
                    }
                }
        }()

        @Test(arguments: supportedProtocolTypeArguments)
        func supported(protocolType: ProtocolSupportedInheritanceType) {
            let (input, expectedResult) = values(for: protocolType)
            assertMacroExpansion(
                input,
                expandedSource: expectedResult,
                macroSpecs: testMacros,
                failureHandler: Issue.record(failure:)
            )
        }

        private func values(
            for protocolType: ProtocolSupportedInheritanceType
        ) -> (input: String, expectedResult: String) {
            let input: String
            let expectedResult: String

            switch protocolType {
            case .caseIterable:
                input = """
                    @PublicWrapper
                    enum Value: CaseIterable {
                        case one
                    }
                    """
                expectedResult = """
                    enum Value: CaseIterable {
                        case one
                    }

                    public struct ValueWrapper: CaseIterable, Equatable, Hashable, Sendable {
                        typealias WrappedValue = Value

                        let wrappedValue: WrappedValue

                        private init(wrappedValue: WrappedValue) {
                            self.wrappedValue = wrappedValue
                        }

                        public static let one = Self.init(wrappedValue: .one)

                        // MARK: CaseIterable

                        public static let allCases = WrappedValue.allCases.map(Self.init)
                    }
                    """
            case .codable:
                input = """
                    @PublicWrapper
                    enum Value: Codable {
                        case one
                    }
                    """
                expectedResult = """
                    enum Value: Codable {
                        case one
                    }

                    public struct ValueWrapper: Codable, Equatable, Hashable, Sendable {
                        typealias WrappedValue = Value

                        let wrappedValue: WrappedValue

                        private init(wrappedValue: WrappedValue) {
                            self.wrappedValue = wrappedValue
                        }

                        public static let one = Self.init(wrappedValue: .one)

                        // MARK: Decodable

                        public init(from decoder: any Decoder) throws {
                            self.wrappedValue = try WrappedValue(from: decoder)
                        }

                        // MARK: Encodable

                        public func encode(to encoder: any Encoder) throws {
                            try wrappedValue.encode(to: encoder)
                        }
                    }
                    """
            case .comparable:
                input = """
                    @PublicWrapper
                    enum Value: Comparable {
                        case one
                        case two
                    }
                    """
                expectedResult = """
                    enum Value: Comparable {
                        case one
                        case two
                    }

                    public struct ValueWrapper: Comparable, Equatable, Hashable, Sendable {
                        typealias WrappedValue = Value

                        let wrappedValue: WrappedValue

                        private init(wrappedValue: WrappedValue) {
                            self.wrappedValue = wrappedValue
                        }

                        public static let one = Self.init(wrappedValue: .one)
                        public static let two = Self.init(wrappedValue: .two)

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
                    }
                    """
            case .customDebugStringConvertible:
                input = """
                    @PublicWrapper
                    enum Value: CustomDebugStringConvertible {
                        case one

                        var debugDescription: String {
                            "hi :)"
                        }
                    }
                    """
                expectedResult = """
                    enum Value: CustomDebugStringConvertible {
                        case one

                        var debugDescription: String {
                            "hi :)"
                        }
                    }

                    public struct ValueWrapper: CustomDebugStringConvertible, Equatable, Hashable, Sendable {
                        typealias WrappedValue = Value

                        let wrappedValue: WrappedValue

                        private init(wrappedValue: WrappedValue) {
                            self.wrappedValue = wrappedValue
                        }

                        public static let one = Self.init(wrappedValue: .one)

                        // MARK: CustomDebugStringConvertible

                        public var debugDescription: String {
                            wrappedValue.debugDescription
                        }
                    }
                    """
            case .customStringConvertible:
                input = """
                    @PublicWrapper
                    enum Value: CustomStringConvertible {
                        case one

                        var description: String {
                            "bye :("
                        }
                    }
                    """
                expectedResult = """
                    enum Value: CustomStringConvertible {
                        case one

                        var description: String {
                            "bye :("
                        }
                    }

                    public struct ValueWrapper: CustomStringConvertible, Equatable, Hashable, Sendable {
                        typealias WrappedValue = Value

                        let wrappedValue: WrappedValue

                        private init(wrappedValue: WrappedValue) {
                            self.wrappedValue = wrappedValue
                        }

                        public static let one = Self.init(wrappedValue: .one)

                        // MARK: CustomStringConvertible

                        public var description: String {
                            wrappedValue.description
                        }
                    }
                    """
            case .decodable:
                input = """
                    @PublicWrapper
                    enum Value: Decodable {
                        case one
                    }
                    """
                expectedResult = """
                    enum Value: Decodable {
                        case one
                    }

                    public struct ValueWrapper: Decodable, Equatable, Hashable, Sendable {
                        typealias WrappedValue = Value

                        let wrappedValue: WrappedValue

                        private init(wrappedValue: WrappedValue) {
                            self.wrappedValue = wrappedValue
                        }

                        public static let one = Self.init(wrappedValue: .one)

                        // MARK: Decodable

                        public init(from decoder: any Decoder) throws {
                            self.wrappedValue = try WrappedValue(from: decoder)
                        }
                    }
                    """
            case .encodable:
                input = """
                    @PublicWrapper
                    enum Value: Encodable {
                        case one
                    }
                    """
                expectedResult = """
                    enum Value: Encodable {
                        case one
                    }

                    public struct ValueWrapper: Encodable, Equatable, Hashable, Sendable {
                        typealias WrappedValue = Value

                        let wrappedValue: WrappedValue

                        private init(wrappedValue: WrappedValue) {
                            self.wrappedValue = wrappedValue
                        }

                        public static let one = Self.init(wrappedValue: .one)

                        // MARK: Encodable

                        public func encode(to encoder: any Encoder) throws {
                            try wrappedValue.encode(to: encoder)
                        }
                    }
                    """
            case .equatable:
                input = """
                    @PublicWrapper
                    enum Value: Equatable {
                        case one
                    }
                    """
                expectedResult = """
                    enum Value: Equatable {
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
            case .hashable:
                input = """
                    @PublicWrapper
                    enum Value: Hashable {
                        case one
                    }
                    """
                expectedResult = """
                    enum Value: Hashable {
                        case one
                    }

                    public struct ValueWrapper: Hashable, Equatable, Sendable {
                        typealias WrappedValue = Value

                        let wrappedValue: WrappedValue

                        private init(wrappedValue: WrappedValue) {
                            self.wrappedValue = wrappedValue
                        }

                        public static let one = Self.init(wrappedValue: .one)
                    }
                    """
            case let .identifiable(type):
                input = """
                    @PublicWrapper
                    enum Value: Identifiable {
                        case one

                        var id: \(type.rawValue) {
                            "\\(self)"
                        }
                    }
                    """
                expectedResult = """
                    enum Value: Identifiable {
                        case one

                        var id: \(type.rawValue) {
                            "\\(self)"
                        }
                    }

                    public struct ValueWrapper: Identifiable, Equatable, Hashable, Sendable {
                        typealias WrappedValue = Value

                        let wrappedValue: WrappedValue

                        private init(wrappedValue: WrappedValue) {
                            self.wrappedValue = wrappedValue
                        }

                        public static let one = Self.init(wrappedValue: .one)

                        // MARK: Identifiable

                        public var id: \(type.rawValue) {
                            wrappedValue.id
                        }
                    }
                    """
            case .sendable:
                input = """
                    @PublicWrapper
                    enum Value: Sendable {
                        case one
                    }
                    """
                expectedResult = """
                    enum Value: Sendable {
                        case one
                    }

                    public struct ValueWrapper: Sendable, Equatable, Hashable {
                        typealias WrappedValue = Value

                        let wrappedValue: WrappedValue

                        private init(wrappedValue: WrappedValue) {
                            self.wrappedValue = wrappedValue
                        }

                        public static let one = Self.init(wrappedValue: .one)
                    }
                    """
            }

            return (input, expectedResult)
        }
    }

#endif

// MARK: - error tests

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
