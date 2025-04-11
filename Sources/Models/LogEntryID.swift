import Foundation

public extension LogEntry {
    struct ID: Hashable, Comparable, Sendable {
        private let rawValue = UUID()
        package let timestamp: TimeInterval
        
        package init(date: Date) {
            self.timestamp = date.timeIntervalSince1970
        }
        
        public static func < (lhs: ID, rhs: ID) -> Bool {
            lhs.timestamp < rhs.timestamp
        }
        
        /// The date the log was created.
        package var createdAt: Date {
            Date(timeIntervalSince1970: timestamp)
        }
    }
}
