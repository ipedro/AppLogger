import Foundation

/// Defines the order in which log entries should be displayed.
///
/// `LogEntrySorting` provides a simple way to control the chronological order
/// of log entries in the UI.
package enum LogEntrySorting: String, CustomStringConvertible, CaseIterable, Identifiable {
    /// Shows oldest logs first
    case ascending
    /// Shows newest logs first
    case descending

    package static let defaultValue: LogEntrySorting = .descending

    package var description: String {
        switch self {
        case .ascending:
            "New Logs Last"
        case .descending:
            "New Logs First"
        }
    }

    package var id: RawValue {
        rawValue
    }
}
