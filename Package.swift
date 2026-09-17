// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

import CompilerPluginSupport
import PackageDescription

// MARK: - Package

let package = Package(
    name: "enum-wrapper-macro",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "EnumWrapper",
            targets: ["EnumWrapper"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Brent-Tunnicliff/swift-format-plugin", from: "2.0.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.0.0"),

        // Stating a range of versions for swift-syntax so we can incrementally support new major versions as they release.
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "603.0.0"..<"604.0.0"),
    ],
    targets: [
        .macro(
            name: "EnumWrapperMacroModule",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "EnumWrapperMacroModuleTests",
            dependencies: [
                "EnumWrapperMacroModule",
                .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax"),
            ]
        ),

        .target(
            name: "EnumWrapper",
            dependencies: ["EnumWrapperMacroModule"]
        ),
        .testTarget(
            name: "EnumWrapperTests",
            dependencies: ["EnumWrapper"]
        ),
    ]
)

// MARK: - Common target settings

// Sets values that are common for every target.
// Plugins cannot contain plugins or swift settings.
for target in package.targets where target.type != .plugin {
    // MARK: Plugins

    let commonPlugins: [PackageDescription.Target.PluginUsage] = [
        .plugin(name: "LintBuildPlugin", package: "swift-format-plugin")
    ]

    target.plugins = (target.plugins ?? []) + commonPlugins

    // MARK: Swift compliler settings

    let commonSwiftSettings: [PackageDescription.SwiftSetting] = [
        // <https://docs.swift.org/latest/documentation/diagnostics/strict-memory-safety/>
        .strictMemorySafety(),

        // Upcoming swift features.
        // To see the list:
        //  - Run `xcrun swiftc -print-supported-features` to see the list of them.
        //  - Or visit <https://www.swift.org/swift-evolution/#?upcoming=true>
        // Details of each can be found at <https://github.com/swiftlang/swift-evolution>.

        // <https://github.com/swiftlang/swift-evolution/blob/main/proposals/0335-existential-any.md>
        .enableUpcomingFeature("ExistentialAny"),

        // <https://github.com/swiftlang/swift-evolution/blob/main/proposals/0409-access-level-on-imports.md>
        .enableUpcomingFeature("InternalImportsByDefault"),

        // <https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md>
        .enableUpcomingFeature("MemberImportVisibility"),

        // <https://github.com/swiftlang/swift-evolution/blob/main/proposals/0470-isolated-conformances.md>
        .enableUpcomingFeature("InferIsolatedConformances"),

        // <https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md>
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),

        // <https://github.com/swiftlang/swift-evolution/blob/main/proposals/0481-weak-let.md>
        .enableUpcomingFeature("ImmutableWeakCaptures"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + commonSwiftSettings
}
