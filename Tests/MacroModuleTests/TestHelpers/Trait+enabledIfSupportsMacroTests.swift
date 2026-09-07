// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import Testing

extension Trait where Self == ConditionTrait {
    static var enabledIfSupportsMacroTests: ConditionTrait {
        .enabled(if: canImportMacroModule, "Platform does not support running Macro tests")
    }

    private static var canImportMacroModule: Bool {
        #if canImport(MacroModule)
            true
        #else
            false
        #endif
    }
}
