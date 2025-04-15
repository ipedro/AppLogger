// MIT License

Copyright(c) 2025 Pedro Almeida

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files(the "Software"), to deal
    in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

    import Foundation

/// Structured content for log entries.
///
/// `LogEntryContent` organizes log messages with their associated function context:
///
/// ```swift
/// // Basic content
/// let basic: LogEntryContent = "fetchUser()"
///
/// // Content with message
/// let detailed = LogEntryContent(
///     function: "validateToken()",
///     message: "Token expired"
/// )
/// ```
public struct LogEntryContent: Sendable {
    /// The function or method name where the log was created.
    public let function: String

    /// Optional additional context or message.
    public let message: String?

    /// Creates a new content instance with function name and optional message.
    ///
    /// - Parameters:
    ///   - function: The name of the function where the log originated
    ///   - message: Optional additional context or details
    public init(function: String, message: String? = .none) {
        self.function = function
        self.message = message
    }
}

extension LogEntryContent: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(function: value)
    }
}

extension LogEntryContent: Filterable {
    package static var filterCriteria: KeyPath<LogEntryContent, String> { \.function }
    package static var filterCriteriaOptional: KeyPath<LogEntryContent, String?>? { \.message }
}
