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
    var logEntryEmoji: Character? { get }
    var logEntryName: String { get }
    var logEntryInfo: LogEntrySourceInfo? { get }
}

public extension LogEntrySourceProtocol {
    var logEntryEmoji: Character? { nil }

    var logEntryName: String {
        let type = "\(type(of: self))"
        guard let sanitizedType = type.split(separator: "<").first else { return type }
        return String(sanitizedType)
    }

    var logEntryInfo: LogEntrySourceInfo? { nil }
}
