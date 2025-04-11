import Foundation
import UIKit

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
