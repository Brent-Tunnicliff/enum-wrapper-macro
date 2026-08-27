// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import PublicWrapper
import Testing

struct PublicWrapperTests {
    @Test
    func wrappingBasicMacro() async throws {
    }
}

@PublicWrapper
enum BasicEnum {
    case one
    case two
}
