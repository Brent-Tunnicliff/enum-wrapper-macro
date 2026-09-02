# public-wrapper-macro

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FBrent-Tunnicliff%2Fpublic-wrapper-macro%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Brent-Tunnicliff/public-wrapper-macro)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FBrent-Tunnicliff%2Fpublic-wrapper-macro%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Brent-Tunnicliff/public-wrapper-macro)
[![Pipeline](https://github.com/Brent-Tunnicliff/public-wrapper-macro/actions/workflows/pipeline.yml/badge.svg)](https://github.com/Brent-Tunnicliff/public-wrapper-macro/actions/workflows/pipeline.yml)
[![Documentation](https://github.com/Brent-Tunnicliff/public-wrapper-macro/actions/workflows/documentation.yml/badge.svg)](https://github.com/Brent-Tunnicliff/public-wrapper-macro/actions/workflows/documentation.yml)
[![](https://img.shields.io/github/license/Brent-Tunnicliff/public-wrapper-macro)](https://github.com/Brent-Tunnicliff/public-wrapper-macro/blob/main/LICENSE)

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
