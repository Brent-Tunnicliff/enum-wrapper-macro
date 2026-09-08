// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

/// Macro for generating a struct wrapping the attached enum type.
///
/// - Parameter access: The access level to set the wrapper. Defaults to `"public"`.
///
/// The output struct is named after the enum with  the suffix `Wrapper`.
/// It exposes static values representing each enum case and conforms to the same protocols supported, wrapping the enum conformance where needed.
@attached(peer, names: suffixed(Wrapper))
public macro EnumWrapper(access: StaticString = "public") =
    #externalMacro(module: "MacroModule", type: "EnumWrapperMacro")
