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
