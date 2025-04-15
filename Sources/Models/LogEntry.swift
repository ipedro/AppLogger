\ MIT License
\ 
\ Copyright (c) 2025 Pedro Almeida
\ 
\ Permission is hereby granted, free of charge, to any person obtaining a copy
\ of this software and associated documentation files (the "Software"), to deal
\ in the Software without restriction, including without limitation the rights
\ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
\ copies of the Software, and to permit persons to whom the Software is
\ furnished to do so, subject to the following conditions:
\ 
\ The above copyright notice and this permission notice shall be included in all
\ copies or substantial portions of the Software.
\ 
\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
\ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
\ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
\ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
\ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
\ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
\ SOFTWARE.
import Foundation

/// A comprehensive log entry that captures detailed information about a logging event.
///
/// `LogEntry` serves as the fundamental building block of the VisualLogger system,
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
    init<S>(
        date: Date = Date(),
        category: LogEntryCategory,
        source: S,
        content: LogEntryContent,
        userInfo: [String: Any]? = nil
    ) where S: LogEntrySourceProtocol {
        id = LogEntryID(date: date)
        self.source = LogEntrySource(source)
        self.category = category
        self.content = content
        self.userInfo = LogEntryUserInfo(userInfo)
    }

    /// Creates a new instance of LogEntry with the given source, category, and content.
    ///
    /// - Parameters:
    ///   - date: The date the log was sent.
    ///   - category: The category or classification of the log entry.
    ///   - source: A custom source type from which the log entry originates.
    ///   - content: The detailed content of the log entry.
    ///   - userInfo: An optional user info.
    init<S>(
        date: Date = Date(),
        category: LogEntryCategory,
        source: S.Type,
        content: LogEntryContent,
        userInfo: [String: Any]? = nil
    ) where S: LogEntrySourceProtocol {
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
