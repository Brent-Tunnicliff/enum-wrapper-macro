# enum-wrapper-macro

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FBrent-Tunnicliff%2Fenum-wrapper-macro%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Brent-Tunnicliff/enum-wrapper-macro)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FBrent-Tunnicliff%2Fenum-wrapper-macro%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Brent-Tunnicliff/enum-wrapper-macro)
[![Pipeline](https://github.com/Brent-Tunnicliff/enum-wrapper-macro/actions/workflows/pipeline.yml/badge.svg)](https://github.com/Brent-Tunnicliff/enum-wrapper-macro/actions/workflows/pipeline.yml)
[![Documentation](https://github.com/Brent-Tunnicliff/enum-wrapper-macro/actions/workflows/documentation.yml/badge.svg)](https://github.com/Brent-Tunnicliff/enum-wrapper-macro/actions/workflows/documentation.yml)
[![](https://img.shields.io/github/license/Brent-Tunnicliff/enum-wrapper-macro)](https://github.com/Brent-Tunnicliff/enum-wrapper-macro/blob/main/LICENSE)

In Swift, enums are very useful types when we want to check against all known cases without needing to handle a default fallback.

But using them publicly in a shared library has risks as adding a new case later is always technically a breaking change.

Sometimes we want to have the benefits of an internal enum that we can switch over, and a public struct that wraps it to allow consumers to pass in the value. The usual solution to that is a whole bunch of wrapping boilerplate code.

This package aims to reduce the boilerplate by auto generating that public struct and conform to some of the same protocols that the enum does via a passthrough.

Due to macro limitations, the wrapper will be generated with the same name as the enum, but with "Wrapper" as a suffix. E.g. `internal enum Token` creates `public struct TokenWrapper`.

## How to use

Import into your package and target as usual: 

```swift
dependencies: [
    .package(url: "https://github.com/Brent-Tunnicliff/enum-wrapper-macro.git", from: "1.0.0")
],
targets: [
    .target(
        name: "Target",
        dependencies: [
            .product(name: "EnumWrapper", package: "enum-wrapper-macro"),
        ]
    ),
]
```

Then wrap an enum:

```swift
import EnumWrapper

@EnumWrapper
enum Theme {
    case light
    case dark
}

// which auto generates:
public struct ThemeWrapper: Equatable, Hashable, Sendable {
    typealias WrappedValue = Theme
    
    let wrappedValue: WrappedValue
    
    private init(wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }

    public static let light = Self.init(wrappedValue: .light)
    public static let dark = Self.init(wrappedValue: .dark)
}
```

## Access modifiers

The wrapper will match the access control level of `let wrappedValue: WrappedValue` with that applied to the enum it wraps.

For example:

```swift
import EnumWrapper

@EnumWrapper
enum Theme {
    case light
    case dark
}

// which auto generates:
public struct ThemeWrapper: Equatable, Hashable, Sendable {
    typealias WrappedValue = Theme
    
    let wrappedValue: WrappedValue
    
    private init(wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }

    public static let light = Self.init(wrappedValue: .light)
    public static let dark = Self.init(wrappedValue: .dark)
}
```

## Supported types

### Protocols

This package supports mapping a wide range of protocols:

- CaseIterable
- Codable
- Comparable
- CustomDebugStringConvertible
- CustomStringConvertible
- Decodable
- Encodable
- Equatable
- Hashable
- Identifiable
- Sendable

Any defined logic for these protocols in the wrapper just call the enum equivalent directly.

If a protocol that we do not support is added to the enum, it will just be ignored and the wrapper will not conform to it.

We only check protocol conformances of the attached enum block, if you split any out over separate extensions then they will not be handled by the wrapper. e.g. if the enum is `@EnumWrapper enum Theme { // ...`, then you add an extension `extension Theme: CaseIterable { // ...`, then the wrapper **does not** conform to `CaseIterable`. 

### Raw values

This package supports mapping a small list of RawValue types:

- Double
- Float
- Int
- Int8
- Int16
- Int32
- Int64
- Int128
- String
- UInt
- UInt8
- UInt16
- UInt32
- UInt64
- UInt128

These will only map if declared explicitly as type of the enum:

```swift
@EnumWrapper
enum DurationOption: Int { 
    case minimum = 100
    // ...
}

public struct DurationOptionWrapper: RawRepresentable, Equatable, Hashable, Sendable {
    typealias WrappedValue = DurationOption

    let wrappedValue: WrappedValue

    private init(wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }

    public static let minimum = Self.init(wrappedValue: .minimum)
    // ...

    // MARK: RawRepresentable

    public typealias RawValue = Int

    public var rawValue: RawValue {
        wrappedValue.rawValue
    }

    public init?(rawValue: RawValue) {
        guard let wrappedValue = WrappedValue(rawValue: rawValue) else {
            return nil
        }
        self.wrappedValue = wrappedValue
    }
}
```

This package **does not support** the enum conformance to RawRepresentable explicitly. That decision was made to avoid extra complexity in trying to work out the type.

## Auto protocol conformance

This package supports automatically conforming the wrapper to protocols that you get for free with enums that do not have associated values.

The following protocols will always be applied whether the enum explicitly does or not:

- Equatable
- Hashable
- Sendable

## No associated types

To avoid extra complexity, the decision was made to not support enum with associated values. These will throw a compile error and will need to be handled manually.

This includes indirect enum cases.   

## Source Stability

The versioning of this package follows [Semantic Versioning](https://semver.org/). Source breaking changes to public API require a new major version.

We'd like this package to quickly embrace Swift language and toolchain improvements, and expect the latest Swift toolchains to be used (i.e. latest public Xcode version). So we will include updating the Swift version of the package as a new minor version bump.

## Disclaimer

I only ever pretend to know what I am doing. If you find something wrong please raise an issue to let me know.
