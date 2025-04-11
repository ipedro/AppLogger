import Foundation

public struct LogEntryID: Hashable, Comparable, Sendable {
    private let rawValue = UUID()
    package let timestamp: TimeInterval

    package init(date: Date) {
        timestamp = date.timeIntervalSince1970
    }

    public static func < (lhs: LogEntryID, rhs: LogEntryID) -> Bool {
        lhs.timestamp < rhs.timestamp
    }

    /// The date the log was created.
    package var createdAt: Date {
        Date(timeIntervalSince1970: timestamp)
    }
}

package extension Collection<LogEntryID> {
    func sort(by strategy: LogEntrySorting) -> [LogEntryID] {
        switch strategy {
        case .ascending: Array(self)
        case .descending: reversed()
        }
    }
}
