// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntaxMacrosGenericTestSupport
import Testing

#if canImport(MacroModule)
    @testable import MacroModule

    extension EnumWrapperMacroTests {
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
                    case .identifiable:
                        [
                            .identifiable("CustomIdentifiable"),
                            .identifiable("Int"),
                            .identifiable("String"),
                            .identifiable("UUID"),
                        ]
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
                    @EnumWrapper
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
                    @EnumWrapper
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
                    @EnumWrapper
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
                    @EnumWrapper
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
                    @EnumWrapper
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
                    @EnumWrapper
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
                    @EnumWrapper
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
                    @EnumWrapper
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
                    @EnumWrapper
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
                    @EnumWrapper
                    enum Value: Identifiable {
                        case one

                        var id: \(type) {
                            "\\(self)"
                        }
                    }
                    """
                expectedResult = """
                    enum Value: Identifiable {
                        case one

                        var id: \(type) {
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

                        public var id: \(type) {
                            wrappedValue.id
                        }
                    }
                    """
            case .sendable:
                input = """
                    @EnumWrapper
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

        /// Unsupported protocols are ignored and don't block generating the rest of the supported wrapper.
        @Test
        func nonSupportedProtocolsIgnored() {
            let input = """
                @EnumWrapper
                enum Value: String, ExpressibleByStringLiteral {
                    case one
                    case two
                    case other

                    init(stringLiteral value: StringLiteralType) {
                        self = Self(rawValue: value) ?? .other
                    }
                }
                """
            let expectedResult = """
                enum Value: String, ExpressibleByStringLiteral {
                    case one
                    case two
                    case other

                    init(stringLiteral value: StringLiteralType) {
                        self = Self(rawValue: value) ?? .other
                    }
                }

                public struct ValueWrapper: RawRepresentable, Equatable, Hashable, Sendable {
                    typealias WrappedValue = Value

                    let wrappedValue: WrappedValue

                    private init(wrappedValue: WrappedValue) {
                        self.wrappedValue = wrappedValue
                    }

                    public static let one = Self.init(wrappedValue: .one)
                    public static let two = Self.init(wrappedValue: .two)
                    public static let other = Self.init(wrappedValue: .other)

                    // MARK: RawRepresentable

                    public typealias RawValue = String

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
