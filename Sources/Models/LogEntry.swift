import Foundation

/// This file defines the LogEntry struct, which represents a log entry in the application.
///
/// A log entry that encapsulates the details for a single log event, including its source, category, and content.
public struct LogEntry: Identifiable, Sendable {
    
    /// A unique identifier for the log entry.
    public let id: LogEntryID
    
    /// The source from which the log entry originates.
    public let source: LogEntrySource
    
    /// The category that describes the type or nature of the log entry.
    public let category: LogEntryCategory
    
    /// The actual content or message of the log entry.
    public let content: LogEntryContent
    
    /// Additional information like a dictionary.
    public let userInfo: LogEntryUserInfo?
    
    /// The date the log was created.
    public var createdAt: Date {
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
        self.id = LogEntryID(date: date)
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
        self.id = LogEntryID(date: date)
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
