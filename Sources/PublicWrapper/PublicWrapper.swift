// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

/// Macro for generating a public struct wrapping the attached enum type.
///
/// The output struct is named after the enum with  the suffix `Wrapper`.
/// It exposes static values representing each enum case and conforms to all the same protocols, wrapping the enum conformance where needed.
@attached(peer, names: suffixed(Wrapper))
public macro PublicWrapper() = #externalMacro(module: "MacroModule", type: "PublicWrapperMacro")
