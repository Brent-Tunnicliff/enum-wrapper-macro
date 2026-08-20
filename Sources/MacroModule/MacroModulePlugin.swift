// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacroModulePlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        PublicWrapperMacro.self,
    ]
}
