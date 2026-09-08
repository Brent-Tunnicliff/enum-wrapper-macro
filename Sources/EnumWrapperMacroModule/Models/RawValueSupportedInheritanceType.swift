// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

/// Raw value inheritance we support.
///
/// Only one can be inherited from.
enum RawValueSupportedInheritanceType: String, CaseIterable {
    case double = "Double"
    case float = "Float"
    case int = "Int"
    case int8 = "Int8"
    case int16 = "Int16"
    case int32 = "Int32"
    case int64 = "Int64"
    case int128 = "Int128"
    case string = "String"
    case uint = "UInt"
    case uint8 = "UInt8"
    case uint16 = "UInt16"
    case uint32 = "UInt32"
    case uint64 = "UInt64"
    case uint128 = "UInt128"
}
