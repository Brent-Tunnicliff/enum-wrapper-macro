// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import EnumWrapper
import Testing

extension EnumWrapperTests {
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

        _ = EnumWithPublicWrapper.value
        _ = EnumWithPackageWrapper.value
        _ = EnumWithInternalWrapper.value
        _ = EnumWithFileprivateWrapper.value
        // We cannot access `EnumWithPrivateWrapper.value` as it is private
    }
}

// MARK: access applied to enum

@EnumWrapper
private enum PrivateEnum {
    case value
}

// Wrapping in an extension to avoid warning that fileprivate can just be private.
extension EnumWrapperTests {
    @EnumWrapper
    fileprivate enum FileprivateEnum {
        case value
    }
}

@EnumWrapper
internal enum InternalEnum {
    case value
}

@EnumWrapper
package enum PackageEnum {
    case value
}

/// Not sure why anyone would want the wrapper on a public enum, but excluding it is more work than just allowing it.
@EnumWrapper
public enum PublicEnum: Sendable {
    case value
}

// MARK: access applied to wrapper

@EnumWrapper(access: "public")
enum EnumWithPublic {
    case value
}

@EnumWrapper(access: "package")
enum EnumWithPackage {
    case value
}

@EnumWrapper(access: "internal")
enum EnumWithInternal {
    case value
}

@EnumWrapper(access: "fileprivate")
enum EnumWithFileprivate {
    case value
}

@EnumWrapper(access: "private")
enum EnumWithPrivate {
    case value
}
