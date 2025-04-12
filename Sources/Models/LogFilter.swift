import Foundation

/// A type that represents a filtering criteria for log entries.
///
/// Filters are the foundation of log searching and organization in VisualLogger.
/// Each filter combines three key components:
/// - A specific type of filter (defined by `Kind`)
/// - The actual search query
/// - A human-readable display name
package struct LogFilter: Hashable {
    package let kind: Kind
    package let query: String
    package let displayName: String

    init(_ kind: Kind, query: String, displayName: String) {
        self.query = query
        self.kind = kind
        self.displayName = displayName
    }
}

package extension LogFilter {
    /// Represents the different aspects of a log entry that can be filtered.
    ///
    /// `Kind` is implemented as an `OptionSet`, allowing multiple
    /// filter criteria to be combined using bitwise operations.
    struct Kind: CustomStringConvertible, Hashable, OptionSet {
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

        package static let source = Kind(rawValue: 1 << 0)
        package static let category = Kind(rawValue: 1 << 1)
        package static let content = Kind(rawValue: 1 << 2)
        package static let userInfo = Kind(rawValue: 1 << 3)

        package static let all: Kind = [
            .source,
            .category,
            .content,
            .userInfo,
        ]
    }
}

extension LogFilter: Comparable {
    package static func < (lhs: LogFilter, rhs: LogFilter) -> Bool {
        lhs.query.localizedStandardCompare(rhs.query) == .orderedAscending
    }
}

extension LogFilter: ExpressibleByStringLiteral {
    package init(stringLiteral value: String) {
        query = value
        displayName = value
        kind = .all
    }
}

package extension Collection where Element == LogFilter {
    func sort(by selection: Set<LogFilter>) -> [LogFilter] {
        sorted { lhs, rhs in
            let lhsActive = selection.contains(lhs)
            let rhsActive = selection.contains(rhs)

            if lhsActive != rhsActive {
                return lhsActive && !rhsActive
            }
            return lhs < rhs
        }
    }
}

// MARK: - Filterable

/// A protocol that defines how a type can be filtered based on string criteria.
///
/// Types conforming to `Filterable` must specify which of their properties
/// should be used for filtering operations.
///
/// ## Discussion
/// The protocol provides two key paths:
/// - `filterCriteria`: The main property to filter on (required)
/// - `filterCriteriaOptional`: A secondary, optional property to filter on
///
/// This dual-property approach allows for flexible filtering strategies,
/// particularly useful when dealing with types that have multiple
/// searchable fields.
package protocol Filterable {
    static var filterCriteria: KeyPath<Self, String> { get }
    static var filterCriteriaOptional: KeyPath<Self, String?>? { get }
}

// MARK: - LogFilter Convertible

/// A protocol that extends `Filterable` to provide automatic conversion
/// to `LogFilter` instances.
///
/// ## Discussion
/// `FilterConvertible` streamlines the process of creating filters from
/// domain objects. By conforming to this protocol, types can specify:
/// - How they should be displayed in filter UI
/// - What kind of filter they represent
/// - Which properties should be considered for filtering
package protocol FilterConvertible: Filterable {
    static var filterDisplayName: KeyPath<Self, String> { get }
    static var filterKind: LogFilter.Kind { get }
}

package extension FilterConvertible {
    var filter: LogFilter {
        LogFilter(
            Self.filterKind,
            query: self[keyPath: Self.filterCriteria],
            displayName: self[keyPath: Self.filterDisplayName]
        )
    }
}

// MARK: - Helpers

extension String: FilterConvertible {
    package static var filterKind: LogFilter.Kind { .all }
    package static var filterDisplayName: KeyPath<String, String> { \.self }
    package static var filterCriteria: KeyPath<String, String> { \.self }
    package static var filterCriteriaOptional: KeyPath<String, String?>? { nil }
}

package extension Filterable {
    func matches(_ filter: LogFilter) -> Bool {
        let value = self[keyPath: Self.filterCriteria]
        if value.localizedCaseInsensitiveContains(filter.query) {
            return true
        }

        if let keyPath = Self.filterCriteriaOptional, let optionalValue = self[keyPath: keyPath] {
            if optionalValue.localizedCaseInsensitiveContains(filter.query) {
                return true
            }
        }
        return false
    }
}
