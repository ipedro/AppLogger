import Foundation

/// This file defines the LogEntry struct, which represents a log entry in the application.
///
/// A log entry that encapsulates the details for a single log event, including its source, category, and content.
public struct LogEntry: Identifiable, Sendable {
    
    /// A unique identifier for the log entry.
    public let id: ID
    
    /// The source from which the log entry originates.
    public let source: Source
    
    /// The category that describes the type or nature of the log entry.
    public let category: Category
    
    /// The actual content or message of the log entry.
    public let content: Content
    
    /// Additional information like a dictionary.
    public let userInfo: UserInfo?
    
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
        category: Category,
        source: Source,
        content: Content,
        userInfo: [String: Any]? = nil
    ) {
        self.id = ID(date: date)
        self.source = source
        self.category = category
        self.content = content
        self.userInfo = UserInfo(userInfo)
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
        category: Category,
        source: some LogEntrySource,
        content: Content,
        userInfo: [String: Any]? = nil
    ) {
        self.id = ID(date: date)
        self.source = Source(source)
        self.category = category
        self.content = content
        self.userInfo = UserInfo(userInfo)
    }
}

package extension [LogEntry] {
    func valuesByID<V>(_ keyPath: KeyPath<LogEntry, V>) -> [LogEntry.ID: V] {
        reduce(into: [:]) { dict, entry in
            dict[entry.id] = entry[keyPath: keyPath]
        }
    }
}
