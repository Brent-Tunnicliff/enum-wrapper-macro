// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import EnumWrapper
import Foundation
import Testing

extension EnumWrapperTests {
    fileprivate func checkIdentifiableWrapsEnum<EnumType, WrapperType>(
        enumValues: (EnumType, EnumType),
        wrapperValues: (WrapperType, WrapperType)
    ) where EnumType: Identifiable, WrapperType: Identifiable, EnumType.ID == WrapperType.ID {
        // Check we didn't accidentally pass the one type in both.
        #expect(EnumType.self != WrapperType.self)

        #expect(wrapperValues.0.id == enumValues.0.id)
        #expect(wrapperValues.0.id != enumValues.1.id)
        #expect(wrapperValues.1.id == enumValues.1.id)
    }
}

// MARK: String

@EnumWrapper
enum StringIdentifiableEnum: Identifiable {
    case one
    case two

    var id: String {
        "\(self)"
    }
}

extension EnumWrapperTests {
    @Test
    func identifiableString() {
        checkIdentifiableWrapsEnum(
            enumValues: (StringIdentifiableEnum.one, .two),
            wrapperValues: (StringIdentifiableEnumWrapper.one, .two)
        )
    }
}

// MARK: Int

@EnumWrapper
enum IntIdentifiableEnum: Identifiable {
    case one
    case two

    var id: Int {
        switch self {
        case .one: 1
        case .two: 2
        }
    }
}

extension EnumWrapperTests {
    @Test
    func identifiableInt() {
        checkIdentifiableWrapsEnum(
            enumValues: (IntIdentifiableEnum.one, .two),
            wrapperValues: (IntIdentifiableEnumWrapper.one, .two)
        )
    }
}

// MARK: UUID

/// Setting access to internal to silence the false warning "Public import of 'Foundation' was not used in public declarations or inlinable code".
///
/// Without `public import Foundation` we get a compile error from the `UUIDIdentifiableEnumWrapper` struct.
/// So the compiler is not able to tell if we actually need it within Macros.
/// This will be annoying for the consumers that also have  the`InternalImportsByDefault` swift feature flag enabled.
/// A work around could be using String as the ID type and mapping the UUID to that, but will leave that to the consumer.
@EnumWrapper(access: "internal")
enum UUIDIdentifiableEnum: Identifiable, Sendable {
    case one
    case two

    /// The id of this enum.
    var id: UUID {
        let value: UInt8
        switch self {
        case .one:
            value = 1
        case .two:
            value = 2
        }

        return UUID(
            uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, value)
        )
    }
}

extension EnumWrapperTests {
    @Test
    func identifiableUUID() {
        checkIdentifiableWrapsEnum(
            enumValues: (UUIDIdentifiableEnum.one, .two),
            wrapperValues: (UUIDIdentifiableEnumWrapper.one, .two)
        )
    }
}

// MARK: Typealias

@EnumWrapper
enum TypealiasIdentifiableEnum: Identifiable {
    case one
    case two

    typealias ID = String

    var id: ID {
        "\(self)"
    }
}

extension EnumWrapperTests {
    @Test
    func identifiableTypealias() {
        checkIdentifiableWrapsEnum(
            enumValues: (TypealiasIdentifiableEnum.one, .two),
            wrapperValues: (TypealiasIdentifiableEnumWrapper.one, .two)
        )
    }
}

// MARK: Generic

@EnumWrapper
enum GenericIdentifiableEnum: Identifiable<String> {
    case one
    case two

    var id: ID {
        "\(self)"
    }
}

extension EnumWrapperTests {
    @Test
    func identifiableGeneric() {
        checkIdentifiableWrapsEnum(
            enumValues: (GenericIdentifiableEnum.one, .two),
            wrapperValues: (GenericIdentifiableEnumWrapper.one, .two)
        )
    }
}
