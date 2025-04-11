import Foundation

public extension LogEntry {
    enum SourceInfo: Hashable, Sendable {
        case file(line: Int)
        case sdk(version: String)
        case error(code: Int)
    }
}
