// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import PublicWrapper
import Testing

struct PublicWrapperTests {
    @Test
    func wrappingBasicMacro() async throws {
//        let wrapper = BasicEnumWrapper.one
    }
}

@PublicWrapper
enum BasicEnum {
    case one
    case two
}
