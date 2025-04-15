\\ MIT License
\\ 
\\ Copyright (c) 2025 Pedro Almeida
\\ 
\\ Permission is hereby granted, free of charge, to any person obtaining a copy
\\ of this software and associated documentation files (the "Software"), to deal
\\ in the Software without restriction, including without limitation the rights
\\ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
\\ copies of the Software, and to permit persons to whom the Software is
\\ furnished to do so, subject to the following conditions:
\\ 
\\ The above copyright notice and this permission notice shall be included in all
\\ copies or substantial portions of the Software.
\\ 
\\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
\\ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
\\ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
\\ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
\\ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
\\ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
\\ SOFTWARE.
import SwiftUI

/// A concrete implementation of a log source with emoji support.
///
/// `LogEntrySource` provides a flexible way to identify where logs come from,
/// with optional emoji for visual distinction and additional contextual information.
///
/// ```swift
/// // Basic source
/// let basicSource = LogEntrySource("NetworkManager")
///
/// // Source with emoji
/// let networkSource = LogEntrySource("🌐", "APIClient")
///
/// // Source with additional info
/// let sdkSource = LogEntrySource(
///     "📱", "FacebookSDK",
///     .sdk(version: "1.2.3")
/// )
/// ```
public struct LogEntrySource: Hashable, Identifiable, Sendable {
    /// A unique identifier derived from the log source name.
    public var id: String { name }

    /// An optional emoji to visually represent the source.
    public let emoji: Character?

    /// The cleaned name identifier for the log source.
    public let name: String

    /// Additional contextual information about the log source.
    public let info: LogEntrySourceInfo?

    /// Initializes a new instance of `LogEntrySource` with a name and optional info.
    ///
    /// - Parameters:
    ///   - name: The name identifier for the log source.
    ///   - info: Optional additional information about the log source. Default is `nil`.
    public init(
        _ name: String,
        _ info: LogEntrySourceInfo? = .none
    ) {
        emoji = nil
        self.info = info
        self.name = Self.cleanName(name)
    }

    /// Initializes a new instance of `LogEntrySource` with an emoji, name, and optional info.
    ///
    /// - Parameters:
    ///   - emoji: An emoji character to represent the log source.
    ///   - name: The name identifier for the log source.
    ///   - info: Optional additional information about the log source. Default is `nil`.
    public init(
        _ emoji: Character,
        _ name: String,
        _ info: LogEntrySourceInfo? = .none
    ) {
        self.emoji = emoji
        self.info = info
        self.name = Self.cleanName(name)
    }

    /// Initializes a new instance of `LogEntrySource` from a source conforming to `LogEntrySourceProtocol`.
    ///
    /// - Parameter source: An object conforming to `LogEntrySourceProtocol`.
    package init<S>(_: S) where S: LogEntrySourceProtocol {
        emoji = S.logEntryEmoji
        info = S.logEntryInfo
        name = Self.cleanName(S.logEntryName)
    }

    /// Initializes a new instance of `LogEntrySource` from a source conforming to `LogEntrySourceProtocol`.
    ///
    /// - Parameter source: A type conforming to `LogEntrySourceProtocol`.
    package init<S>(_: S.Type) where S: LogEntrySourceProtocol {
        emoji = S.logEntryEmoji
        info = S.logEntryInfo
        name = Self.cleanName(S.logEntryName)
    }

    /// Returns a cleaned version of the provided name by removing a ".swift" suffix if present.
    ///
    /// - Parameter name: The original source name.
    /// - Returns: A cleaned version of the name without a ".swift" suffix, if applicable.
    private static func cleanName(_ name: String) -> String {
        if name.hasSuffix(".swift") {
            name.replacingOccurrences(of: ".swift", with: "")
        } else {
            name
        }
    }
}

extension LogEntrySource: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension LogEntrySource: Comparable {
    public static func < (lhs: LogEntrySource, rhs: LogEntrySource) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}

extension LogEntrySource: CustomStringConvertible {
    public var description: String {
        if let emoji {
            "\(emoji) \(name)"
        } else {
            name
        }
    }
}

extension LogEntrySource: FilterConvertible {
    package static var filterKind: LogFilterKind { .source }
    package static var filterDisplayName: KeyPath<LogEntrySource, String> { \.description }
    package static var filterCriteria: KeyPath<LogEntrySource, String> { \.name }
    package static var filterCriteriaOptional: KeyPath<LogEntrySource, String?>? { nil }
}
