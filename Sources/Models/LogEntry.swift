import Foundation

/// A comprehensive log entry that captures detailed information about a logging event.
///
/// `LogEntry` serves as the fundamental building block of the AppLogger system,
/// encapsulating all the metadata and content needed for effective logging:
///
/// ```swift
/// // Create a basic log entry
/// let entry = LogEntry(
///     category: .warning,
///     source: "NetworkManager",
///     content: "Connection timeout"
/// )
///
/// // Create a detailed log entry
/// let detailedEntry = LogEntry(
///     category: .error,
///     source: LogEntrySource("🌐", "APIClient"),
///     content: LogEntryContent(
///         function: "fetchUser(id:)",
///         message: "Invalid response"
///     ),
///     userInfo: ["statusCode": 404]
/// )
/// ```
public struct LogEntry: Sendable {
    /// A unique identifier for the log entry.
    package let id: LogEntryID

    /// The source from which the log entry originates.
    package let source: LogEntrySource

    /// The category that describes the type or nature of the log entry.
    package let category: LogEntryCategory

    /// The actual content or message of the log entry.
    package let content: LogEntryContent

    /// Additional information like a dictionary.
    package let userInfo: LogEntryUserInfo?

    /// The date the log was created.
    package var createdAt: Date {
        id.createdAt
    }
}

public extension LogEntry {
    /// Creates a new instance of LogEntry with the given source, category, and content.
    ///
    /// - Parameters:
    ///   - date: The date the log was sent.
    ///   - category: The category or classification of the log entry.
    ///   - source: The source from which the log entry originates.
    ///   - content: The detailed content of the log entry.
    ///   - userInfo: An optional user info.
    init(
        date: Date = Date(),
        category: LogEntryCategory,
        source: LogEntrySource,
        content: LogEntryContent,
        userInfo: [String: Any]? = nil
    ) {
        id = LogEntryID(date: date)
        self.source = source
        self.category = category
        self.content = content
        self.userInfo = LogEntryUserInfo(userInfo)
    }

    /// Creates a new instance of LogEntry with the given source, category, and content.
    ///
    /// - Parameters:
    ///   - date: The date the log was sent.
    ///   - category: The category or classification of the log entry.
    ///   - source: A custom source from which the log entry originates.
    ///   - content: The detailed content of the log entry.
    ///   - userInfo: An optional user info.
    init(
        date: Date = Date(),
        category: LogEntryCategory,
        source: some LogEntrySourceProtocol,
        content: LogEntryContent,
        userInfo: [String: Any]? = nil
    ) {
        id = LogEntryID(date: date)
        self.source = LogEntrySource(source)
        self.category = category
        self.content = content
        self.userInfo = LogEntryUserInfo(userInfo)
    }
}

package extension [LogEntry] {
    func valuesByID<V>(_ keyPath: KeyPath<LogEntry, V>) -> [LogEntryID: V] {
        reduce(into: [:]) { dict, entry in
            dict[entry.id] = entry[keyPath: keyPath]
        }
    }
}
