// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import EnumWrapper
import Foundation
import Testing

@EnumWrapper
enum CodableEnum: Codable {
    case one
    case two
}

extension EnumWrapperTests {
    @Test
    func codableWrapsTheEnumLogic() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let dataOne = try encoder.encode(CodableEnumWrapper.one)
        let dataTwo = try encoder.encode(CodableEnumWrapper.two)

        #expect(dataOne != dataTwo)

        try #expect(decoder.decode(CodableEnumWrapper.self, from: dataOne) == .one)
        try #expect(decoder.decode(CodableEnum.self, from: dataOne) == .one)
        try #expect(decoder.decode(CodableEnumWrapper.self, from: dataTwo) == .two)
        try #expect(decoder.decode(CodableEnum.self, from: dataTwo) == .two)
    }
}
