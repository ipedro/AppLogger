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

public extension LogEntrySourceProtocol {
    static var logEntryEmoji: Character? { nil }

    static var logEntryName: String {
        let type = "\(type(of: self))"
        guard let sanitizedType = type.split(separator: "<").first else { return type }
        return String(sanitizedType)
    }

    static var logEntryInfo: LogEntrySourceInfo? { nil }
}
