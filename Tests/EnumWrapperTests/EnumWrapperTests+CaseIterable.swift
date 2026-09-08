// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import EnumWrapper
import Testing

@EnumWrapper
enum CaseIterableEnum: CaseIterable {
    case one
    case two
    case three
    case four
    case five
}

extension EnumWrapperTests {
    @Test
    func wrapperAllCasesMatchesEnumOrder() {
        let enumAllCases = CaseIterableEnum.allCases
        let wrapperAllCases = CaseIterableEnumWrapper.allCases

        #expect(wrapperAllCases.count == enumAllCases.count)
        #expect(wrapperAllCases.map(\.wrappedValue) == enumAllCases)
    }
}
