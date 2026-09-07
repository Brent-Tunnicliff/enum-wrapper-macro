// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Foundation
import PublicWrapper
import Testing

@PublicWrapper
enum BasicEnum {
    case one
    case two
}

// This file contains the basic tests that apply to all wrappers.
// Inheritance logic is tested via extensions in seperate files.
struct PublicWrapperTests {
    @Test
    func wrapperContainsSameValueAsTheEnum() {
        let cases: [(BasicEnum, BasicEnumWrapper)] = [
            (.one, .one),
            (.two, .two),
        ]

        for (`enum`, wrapper) in cases {
            #expect(wrapper.wrappedValue == `enum`)
        }

        #expect(BasicEnumWrapper.one.wrappedValue != .two)
    }

    @Test
    func wrapperIsEquatable() {
        #expect(BasicEnumWrapper.one == .one)
        #expect(BasicEnumWrapper.one != .two)
    }

    @Test
    func wrapperIsHashable() {
        #expect(BasicEnumWrapper.one.hashValue == BasicEnumWrapper.one.hashValue)
        #expect(BasicEnumWrapper.one.hashValue != BasicEnumWrapper.two.hashValue)
    }

    /// Checks the wrapper is Sendable.
    ///
    /// This test is only verifying compile time Sendable checks instead of runtime checks.
    /// So the test can never fail outside of compile time failure if the wrapper stops adding `Sendable`.
    /// We cannot do things like `if value is Sendable { ... }`.
    @Test
    func wrapperIsSendable() async {
        final class SendableClass: Sendable {
            static let shared = SendableClass()
            let value: BasicEnumWrapper = .one
        }

        await withTaskGroup { group in
            for _ in 0..<10 {
                group.addTask { @concurrent in
                    _ = SendableClass.shared.value
                }

                group.addTask { @MainActor in
                    _ = SendableClass.shared.value
                }
            }
        }
    }
}
