// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import PublicWrapper
import Testing

@PublicWrapper
enum CustomStringConvertibleEnum: CustomStringConvertible {
    case value
    case otherValue

    var description: String {
        switch self {
        case .value:
            "Snorlax is my spirit Pokemon."
        case .otherValue:
            "Do you have one?"
        }
    }
}

extension PublicWrapperTests {
    @Test
    func descriptionWrapsAsExpected() throws {
        let valueDescription = CustomStringConvertibleEnum.value.description
        let otherValueDescription = CustomStringConvertibleEnum.otherValue.description

        #expect(CustomStringConvertibleEnumWrapper.value.description == valueDescription)
        #expect(CustomStringConvertibleEnumWrapper.value.description != otherValueDescription)
        #expect(CustomStringConvertibleEnumWrapper.otherValue.description == otherValueDescription)
    }
}
