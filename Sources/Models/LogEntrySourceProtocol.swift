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
import UIKit

/// A protocol that defines how types can serve as log entry sources.
///
/// `LogEntrySourceProtocol` makes it easy to turn any type into a logging source
/// with minimal configuration:
///
/// ```swift
/// struct NetworkService: LogEntrySourceProtocol {
///     // Customize the emoji (optional)
///     var logEntryEmoji: Character? { "🌐" }
///
///     // Name is automatically derived from type name,
///     // but can be customized if needed
///     var logEntryName: String { "API Client" }
///
///     // Add extra context (optional)
///     var logEntryInfo: LogEntrySourceInfo? {
///         .sdk(version: "1.0.0")
///     }
/// }
/// ```
public protocol LogEntrySourceProtocol {
    /// An optional custom emoji.
    static var logEntryEmoji: Character? { get }
    /// Name is automatically derived from type name, can be customized if needed.
    static var logEntryName: String { get }
    /// Extra context (optional).
    static var logEntryInfo: LogEntrySourceInfo? { get }
}

// MARK: - Default Values

public extension LogEntrySourceProtocol {
    static var logEntryEmoji: Character? { nil }
    static var logEntryName: String { "\(Self.self)" }
    static var logEntryInfo: LogEntrySourceInfo? { nil }
}
