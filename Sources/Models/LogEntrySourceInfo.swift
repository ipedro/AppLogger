import Foundation

public enum LogEntrySourceInfo: Hashable, Sendable {
    case file(line: Int)
    case sdk(version: String)
    case error(code: Int)
}
