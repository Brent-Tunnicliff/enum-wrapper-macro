// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

#if canImport(MacroModule)
    @testable import MacroModule
#endif

@Suite(.enabledIfSupportsMacroTests)
struct PublicWrapperMacroTests {
    let testMacros: [String: MacroSpec]

    init() {
        #if canImport(MacroModule)
            self.testMacros = ["PublicWrapper": MacroSpec(type: PublicWrapperMacro.self)]
        #else
            self.testMacros = [:]
        #endif
    }

    // All the tests are in other files as extensions to this type.
}
