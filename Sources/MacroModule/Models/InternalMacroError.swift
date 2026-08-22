// Copyright © 2026 Brent Tunnicliff <brent@tunnicliff.dev>

/// Something went unexpectedly wrong in the macro that cannot be resolved by the consumer.
struct InternalMacroError: Error, CustomStringConvertible {
    let description: String

    init(
        _ message: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.description = "\(Self.self): \(message), (\(file):\(function):\(line):\(column))"
    }
}
