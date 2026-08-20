# public-wrapper-macro

In Swift, enums are very useful types when we want to check against all known cases without needing to handle a default fallback.

But using them publicly in a shared library has risks as adding a new case later is always technically a breaking change.

Sometimes we want to have the benefits of an internal enum that we can switch over, and a public struct that wraps it to allow consumers to pass in the value.

This package aims to reduce the boilerplate by auto generating that public struct and conform to any protocols that the enum does too as a passthrough.

## Source Stability

The versioning of this package follows [Semantic Versioning](https://semver.org/). Source breaking changes to public API require a new major version.

We'd like this package to quickly embrace Swift language and toolchain improvements, and expect the latest Swift toolchains to be used (i.e. latest public Xcode version). So we will include updating the Swift version of the package as a new minor version bump.

## Disclaimer

I only ever pretend to know what I am doing. If you find something wrong please raise an issue to let me know.

This project is open source and open to anyone to use as they see fit.
But I am building this with myself as the main target audience, so this will not be published anywhere.
