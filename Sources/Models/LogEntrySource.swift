import SwiftUI

public extension LogEntry {
    struct Source: Hashable, Identifiable, Sendable {
        public var id: String { name }
        public let emoji: Character?
        public let name: String
        public let info: SourceInfo?
        
        public init(
            _ name: String,
            _ info: SourceInfo? = .none
        ) {
            self.emoji = nil
            self.info = info
            self.name = Self.cleanName(name)
        }
        
        public init(
            _ emoji: Character,
            _ name: String,
            _ info: SourceInfo? = .none
        ) {
            self.emoji = emoji
            self.info = info
            self.name = Self.cleanName(name)
        }
        
        package init(_ source: some LogEntrySource) {
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
}

extension LogEntry.Source: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension LogEntry.Source: Comparable {
    public static func < (lhs: LogEntry.Source, rhs: LogEntry.Source) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}

extension LogEntry.Source: CustomStringConvertible {
    public var description: String {
        if let emoji {
            "\(emoji) \(name)"
        } else {
            name
        }
    }
}

extension LogEntry.Source: FilterConvertible {
    package static var filterKind: Filter.Kind { .source }
    package static var filterDisplayName: KeyPath<LogEntry.Source, String> { \.description }
    package static var filterQuery: KeyPath<LogEntry.Source, String> { \.name }
}
