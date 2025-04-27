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

/// A lightweight value type that describes a single log message.
///
/// Each entry consists of:
/// * **title** – the main identifier, typically the function or subsystem that produced the log.
/// * **subtitle** – optional extra context (for example an error description or IDs).
///
/// ### Examples
/// ```swift
/// // Simplest form – created via string literal
/// let basic: LogEntryContent = "fetchUser()"
///
/// // With additional context
/// let detailed = LogEntryContent(
///     title: "validateToken()",
///     subtitle:  "Token expired"
/// )
/// ```
public struct LogEntryContent: Sendable {
    /// The title or method name where the log was created.
    public let title: String

    /// Optional additional context or subtitle.
    public let subtitle: String?

    /// Creates a new content value.
    ///
    /// - Parameters:
    ///   - title: Primary text, usually a function name or task identifier.
    ///   - subtitle:  Optional secondary text providing more detail.
    public init(title: String, subtitle: String? = .none) {
        self.title = title
        self.subtitle = subtitle
    }
}

extension LogEntryContent: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(title: value)
    }
}

extension LogEntryContent: Filterable {
    package static var filterCriteria: KeyPath<LogEntryContent, String> { \.title }
    package static var filterCriteriaOptional: KeyPath<LogEntryContent, String?>? { \.subtitle }
}
