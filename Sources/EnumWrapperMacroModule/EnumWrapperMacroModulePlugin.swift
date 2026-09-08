// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct EnumWrapperMacroModulePlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        EnumWrapperMacro.self
    ]
}
