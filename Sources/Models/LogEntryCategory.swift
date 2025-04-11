import Foundation

public extension LogEntryCategory {
    static let verbose = Self("🗯", "Verbose")
    static let debug = Self("🔹", "Debug")
    static let info = Self("ℹ️", "Info")
    static let notice = Self("✳️", "Notice")
    static let warning = Self("⚠️", "Warning")
    static let error = Self("💥", "Error")
    static let severe = Self("💣", "Severe")
    static let alert = Self("‼️", "Alert")
    static let emergency = Self("🚨", "Emergency")
}

/// A structure that represents a log entry category with an optional emoji and a debug name.
///
/// It provides computed properties for representing the emoji as a string and for creating a display name by combining the emoji (if available) with the debug name.
public struct LogEntryCategory: Hashable, Sendable {
    /// An optional emoji associated with this log entry category.
    public let emoji: Character?
    /// A string identifier used for debugging and identifying the log entry category.
    public let name: String
    
    /// Initializes a new log entry category with the given debug name.
    ///
    /// - Parameter name: A string identifier for the category.
    public init(_ name: String) {
        self.emoji = nil
        self.name = name
    }
    
    /// Initializes a new log entry category with the given emoji and debug name.
    ///
    /// - Parameters:
    ///   - emoji: An emoji representing the category.
    ///   - name: A string identifier for the category.
    public init(_ emoji: Character, _ name: String) {
        self.emoji = emoji
        self.name = name
    }
}

extension LogEntryCategory: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension LogEntryCategory: Comparable {
    public static func < (lhs: LogEntryCategory, rhs: LogEntryCategory) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}

extension LogEntryCategory: CustomStringConvertible {
    public var description: String {
        if let emoji {
            "\(emoji) \(name)"
        } else {
            name
        }
    }
}

extension LogEntryCategory: FilterConvertible {
    package static var filterKind: Filter.Kind { .category }
    package static var filterDisplayName: KeyPath<LogEntryCategory, String> { \.description }
    package static var filterQuery: KeyPath<LogEntryCategory, String> { \.name }
}
