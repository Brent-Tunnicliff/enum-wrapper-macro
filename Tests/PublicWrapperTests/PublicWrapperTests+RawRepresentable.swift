// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import PublicWrapper
import Testing

@PublicWrapper
enum StringEnum: String {
    case start
    case end
}

@PublicWrapper
enum IntEnum: Int {
    case zero
    case one
}

extension PublicWrapperTests {
    @Test
    func wrapperContainsSameRawValue() {
        #expect(StringEnumWrapper.start.rawValue == StringEnum.start.rawValue)
        #expect(StringEnumWrapper.end.rawValue == StringEnum.end.rawValue)

        #expect(IntEnumWrapper.zero.rawValue == IntEnum.zero.rawValue)
        #expect(IntEnumWrapper.one.rawValue == IntEnum.one.rawValue)
    }

    @Test
    func wrapperRawValueInit() {
        #expect(StringEnumWrapper(rawValue: StringEnum.start.rawValue) == .start)
        #expect(StringEnumWrapper(rawValue: StringEnum.end.rawValue) == .end)
        #expect(StringEnumWrapper(rawValue: "other") == nil)

        #expect(IntEnumWrapper(rawValue: IntEnum.zero.rawValue) == .zero)
        #expect(IntEnumWrapper(rawValue: IntEnum.one.rawValue) == .one)
        #expect(IntEnumWrapper(rawValue: -1) == nil)
    }
}
