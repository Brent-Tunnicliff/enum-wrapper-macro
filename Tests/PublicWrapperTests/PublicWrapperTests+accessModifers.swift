// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import PublicWrapper
import Testing

extension PublicWrapperTests {
    /// Checks that various access levels on the enum still compile file.
    ///
    /// Does not actually assert anything, just compile time checks.
    /// The macro module tests already check that the syntax passes
    @Test
    func variousAccessModifiersOnEnumStillCompile() {
        // We cannot access `PrivateEnumWrapper.value.wrappedValue`
        _ = PrivateEnumWrapper.value
        _ = FileprivateEnumWrapper.value.wrappedValue
        _ = InternalEnumWrapper.value.wrappedValue
        _ = PackageEnumWrapper.value.wrappedValue
        _ = PublicEnumWrapper.value.wrappedValue
    }
}

@PublicWrapper
private enum PrivateEnum {
    case value
}

// Wrapping in an extension to avoid warning that fileprivate can just be private.
extension PublicWrapperTests {
    @PublicWrapper
    fileprivate enum FileprivateEnum {
        case value
    }
}

@PublicWrapper
internal enum InternalEnum {
    case value
}

@PublicWrapper
package enum PackageEnum {
    case value
}

/// Not sure why anyone would want the wrapper on a public enum, but excluding it is more work than just allowing it.
@PublicWrapper
public enum PublicEnum: Sendable {
    case value
}
