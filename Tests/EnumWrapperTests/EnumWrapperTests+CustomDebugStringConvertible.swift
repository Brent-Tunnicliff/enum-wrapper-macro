// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import EnumWrapper
import Testing

@EnumWrapper
enum CustomDebugStringConvertibleEnum: CustomDebugStringConvertible {
    case value
    case otherValue

    var debugDescription: String {
        switch self {
        case .value:
            "Hello reader."
        case .otherValue:
            "I hope you are having a good day!"
        }
    }
}

extension EnumWrapperTests {
    @Test
    func debugDescriptionWrapsAsExpected() throws {
        let valueDebugDescription = CustomDebugStringConvertibleEnum.value.debugDescription
        let otherValueDebugDescription = CustomDebugStringConvertibleEnum.otherValue.debugDescription

        #expect(CustomDebugStringConvertibleEnum.value.debugDescription == valueDebugDescription)
        #expect(CustomDebugStringConvertibleEnum.value.debugDescription != otherValueDebugDescription)
        #expect(CustomDebugStringConvertibleEnum.otherValue.debugDescription == otherValueDebugDescription)
    }
}
