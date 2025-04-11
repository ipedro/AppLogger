import SwiftUI

public struct LogEntrySource: Hashable, Identifiable, Sendable {
    public var id: String { name }
    public let emoji: Character?
    public let name: String
    public let info: LogEntrySourceInfo?
    
    public init(
        _ name: String,
        _ info: LogEntrySourceInfo? = .none
    ) {
        self.emoji = nil
        self.info = info
        self.name = Self.cleanName(name)
    }
    
    public init(
        _ emoji: Character,
        _ name: String,
        _ info: LogEntrySourceInfo? = .none
    ) {
        self.emoji = emoji
        self.info = info
        self.name = Self.cleanName(name)
    }
    
    package init(_ source: some LogEntrySourceProtocol) {
        emoji = source.logEntryEmoji
        info = source.logEntryInfo
        name = Self.cleanName(source.logEntryName)
    }
    
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
    package static var filterKind: Filter.Kind { .source }
    package static var filterDisplayName: KeyPath<LogEntrySource, String> { \.description }
    package static var filterQuery: KeyPath<LogEntrySource, String> { \.name }
}
