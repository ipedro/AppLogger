import Foundation

/// A unique identifier for log entries with built-in temporal ordering.
package struct LogEntryID: Hashable, Comparable, Sendable {
    private let rawValue = UUID()
    package let timestamp: TimeInterval

    package init(date: Date) {
        timestamp = date.timeIntervalSince1970
    }

    package static func < (lhs: LogEntryID, rhs: LogEntryID) -> Bool {
        lhs.timestamp > rhs.timestamp
    }

    /// The date the log was created.
    package var createdAt: Date {
        Date(timeIntervalSince1970: timestamp)
    }
}
