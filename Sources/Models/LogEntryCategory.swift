// MIT License
//
// Copyright (c) 2025 Pedro Almeida
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

public extension LogEntryCategory {
    package enum Default: String, CaseIterable {
        /// Basic informational messages for detailed debugging.
        case verbose = "Verbose"
        /// Debug-level messages for development purposes.
        case debug = "Debug"
        /// General information messages.
        case info = "Info"
        /// Notable events that are worth attention.
        case notice = "Notice"
        /// Warning messages for potential issues.
        case warning = "Warning"
        /// Error messages for recoverable failures.
        case error = "Error"
        /// Severe error messages for critical issues.
        case severe = "Severe"
        /// Alert messages requiring immediate attention.
        case alert = "Alert"
        /// Emergency messages for system-wide failures.
        case emergency = "Emergency"

        var emoji: Character {
            switch self {
            case .verbose: "💬"
            case .debug: "🐞"
            case .info: "ℹ️"
            case .notice: "✳️"
            case .warning: "⚠️"
            case .error: "💥"
            case .severe: "💣"
            case .alert: "‼️"
            case .emergency: "🚨"
            }
        }

        package func category() -> LogEntryCategory {
            LogEntryCategory(emoji, rawValue)
        }
    }

    /// Basic informational messages for detailed debugging.
    static let verbose = Default.verbose.category()
    /// Debug-level messages for development purposes.
    static let debug = Default.debug.category()
    /// General information messages.
    static let info = Default.info.category()
    /// Notable events that are worth attention.
    static let notice = Default.notice.category()
    /// Warning messages for potential issues.
    static let warning = Default.warning.category()
    /// Error messages for recoverable failures.
    static let error = Default.error.category()
    /// Severe error messages for critical issues.
    static let severe = Default.severe.category()
    /// Alert messages requiring immediate attention.
    static let alert = Default.alert.category()
    /// Emergency messages for system-wide failures.
    static let emergency = Default.emergency.category()
}

/// A structure that represents a log entry category with an optional emoji and a debug name.
///
/// It provides computed properties for representing the emoji as a string and for creating a display name by combining the emoji (if available) with the debug name.
///
/// ```swift
/// // Create a category with just a name
/// let basic = LogEntryCategory("Custom")
///
/// // Create a category with emoji and name
/// let network = LogEntryCategory("🌐", "Network")
///
/// // Use string literal initialization
/// let simple: LogEntryCategory = "Database"
///
/// // Use predefined categories
/// let error = LogEntryCategory.error
/// let warning = LogEntryCategory.warning
/// ```
public struct LogEntryCategory: Hashable, Sendable {
    /// An optional emoji associated with this log entry category.
    public let emoji: Character?
    /// A string identifier used for debugging and identifying the log entry category.
    public let name: String

    /// Initializes a new log entry category with the given debug name.
    ///
    /// - Parameter name: A string identifier for the category.
    public init(_ name: String) {
        emoji = nil
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
    package static var filterKind: LogFilterKind { .category }
    package static var filterDisplayName: KeyPath<LogEntryCategory, String> { \.description }
    package static var filterCriteria: KeyPath<LogEntryCategory, String> { \.name }
    package static var filterCriteriaOptional: KeyPath<LogEntryCategory, String?>? { nil }
}
