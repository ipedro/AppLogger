import Foundation

/// Represents the different aspects of a log entry that can be filtered.
///
/// `LogFilterKind` is implemented as an `OptionSet`, allowing multiple
/// filter criteria to be combined using bitwise operations.
package struct LogFilterKind: Sendable, CustomStringConvertible, Hashable, OptionSet {
    package let rawValue: Int8

    package var description: String {
        var components = [String]()
        if contains(.source) { components.append("source") }
        if contains(.category) { components.append("category") }
        if contains(.content) { components.append("content") }
        if contains(.userInfo) { components.append("userInfo") }
        return components.joined(separator: ", ")
    }

    package init(rawValue: Int8) {
        self.rawValue = rawValue
    }

    package static let source = LogFilterKind(rawValue: 1 << 0)
    package static let category = LogFilterKind(rawValue: 1 << 1)
    package static let content = LogFilterKind(rawValue: 1 << 2)
    package static let userInfo = LogFilterKind(rawValue: 1 << 3)

    package static let all: LogFilterKind = [
        .source,
        .category,
        .content,
        .userInfo,
    ]
}
