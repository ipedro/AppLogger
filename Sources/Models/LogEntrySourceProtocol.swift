import Foundation
import UIKit

public protocol LogEntrySource {
    var logEntryEmoji: Character? { get }
    var logEntryName: String { get }
    var logEntryInfo: LogEntry.SourceInfo? { get }
}

public extension LogEntrySource {
    var logEntryEmoji: Character? { nil }
    
    var logEntryName: String {
        let type = "\(type(of: self))"
        guard let sanitizedType = type.split(separator: "<").first else { return type }
        return String(sanitizedType)
    }
    
    var logEntryInfo: LogEntry.SourceInfo? { nil }
}
