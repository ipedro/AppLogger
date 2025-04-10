//  Copyright (c) 2022 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import struct Foundation.Date

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
