// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

/// Macro for generating a struct wrapping the attached enum type.
///
/// - Parameter access: The access level to set the wrapper. Supported values are `"public"`, `"package"`, `"internal"`, `"fileprivate"`, and `"private"`. Defaults to `"public"`.
///
/// The output struct is named after the enum with  the suffix `Wrapper`.
/// It exposes static values representing each enum case and conforms to the same protocols supported, wrapping the enum conformance where needed.
///
/// Example:
/// ```swift
/// @EnumWrapper
/// enum SimpleEnum {
///     case one
///     case two
/// }
///
/// // Generates the following wrapper struct:
/// public struct SimpleEnumWrapper: Equatable, Hashable, Sendable {
///     typealias WrappedValue = SimpleEnum
///
///     let wrappedValue: WrappedValue
///
///     private init(wrappedValue: WrappedValue) {
///         self.wrappedValue = wrappedValue
///     }
///
///     public static let one = Self.init(wrappedValue: .one)
///     public static let two = Self.init(wrappedValue: .two)
/// }
/// ```
@attached(peer, names: suffixed(Wrapper))
public macro EnumWrapper(access: StaticString = "public") =
    #externalMacro(module: "MacroModule", type: "EnumWrapperMacro")
