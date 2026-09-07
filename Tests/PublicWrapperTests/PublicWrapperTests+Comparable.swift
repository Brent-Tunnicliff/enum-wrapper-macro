// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import PublicWrapper
import Testing

@PublicWrapper
enum ComparableEnum: Comparable {
    case high
    case low
    case middle

    static func < (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.low, .middle),
            (.low, .high),
            (.middle, .high):
            true
        default: false
        }
    }
}

extension PublicWrapperTests {
    // Comparing both the enum and the wrapper so we have a control to compare against.
    @Test
    func comparable() throws {
        // MARK: low

        #expect(ComparableEnum.low <= .low)
        #expect(ComparableEnumWrapper.low <= .low)

        #expect(ComparableEnum.low == .low)
        #expect(ComparableEnumWrapper.low == .low)

        #expect(ComparableEnum.low >= .low)
        #expect(ComparableEnumWrapper.low >= .low)

        #expect(ComparableEnum.low < .middle)
        #expect(ComparableEnumWrapper.low < .middle)

        #expect(ComparableEnum.low <= .middle)
        #expect(ComparableEnumWrapper.low <= .middle)

        #expect(ComparableEnum.low < .high)
        #expect(ComparableEnumWrapper.low < .high)

        #expect(ComparableEnum.low <= .high)
        #expect(ComparableEnumWrapper.low <= .high)

        // MARK: middle

        #expect(ComparableEnum.middle > .low)
        #expect(ComparableEnumWrapper.middle > .low)

        #expect(ComparableEnum.middle >= .low)
        #expect(ComparableEnumWrapper.middle >= .low)

        #expect(ComparableEnum.middle <= .middle)
        #expect(ComparableEnumWrapper.middle <= .middle)

        #expect(ComparableEnum.middle == .middle)
        #expect(ComparableEnumWrapper.middle == .middle)

        #expect(ComparableEnum.middle >= .middle)
        #expect(ComparableEnumWrapper.middle >= .middle)

        #expect(ComparableEnum.middle < .high)
        #expect(ComparableEnumWrapper.middle < .high)

        #expect(ComparableEnum.middle <= .high)
        #expect(ComparableEnumWrapper.middle <= .high)

        // MARK: high
        #expect(ComparableEnum.high > .low)
        #expect(ComparableEnumWrapper.high > .low)

        #expect(ComparableEnum.high >= .low)
        #expect(ComparableEnumWrapper.high >= .low)

        #expect(ComparableEnum.high > .middle)
        #expect(ComparableEnumWrapper.high > .middle)

        #expect(ComparableEnum.high >= .middle)
        #expect(ComparableEnumWrapper.high >= .middle)

        #expect(ComparableEnum.high <= .high)
        #expect(ComparableEnumWrapper.high <= .high)

        #expect(ComparableEnum.high == .high)
        #expect(ComparableEnumWrapper.high == .high)

        #expect(ComparableEnum.high >= .high)
        #expect(ComparableEnumWrapper.high >= .high)
    }
}
