\ MIT License
\ 
\ Copyright (c) 2025 Pedro Almeida
\ 
\ Permission is hereby granted, free of charge, to any person obtaining a copy
\ of this software and associated documentation files (the "Software"), to deal
\ in the Software without restriction, including without limitation the rights
\ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
\ copies of the Software, and to permit persons to whom the Software is
\ furnished to do so, subject to the following conditions:
\ 
\ The above copyright notice and this permission notice shall be included in all
\ copies or substantial portions of the Software.
\ 
\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
\ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
\ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
\ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
\ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
\ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
\ SOFTWARE.
import Foundation

/// A type that represents a filtering criteria for log entries.
///
/// Filters are the foundation of log searching and organization in VisualLogger.
/// Each filter combines three key components:
/// - A specific type of filter (defined by `Kind`)
/// - The actual search query
/// - A human-readable display name
package struct LogFilter: Hashable, Sendable {
    package let kind: LogFilterKind
    package let query: String
    package let displayName: String

    init(_ kind: LogFilterKind, query: String, displayName: String) {
        self.query = query
        self.kind = kind
        self.displayName = displayName
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
    static var filterKind: LogFilterKind { get }
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
    private var inQuotes: String { "\"\(self)\"" }
    package static var filterKind: LogFilterKind { .all }
    package static var filterDisplayName: KeyPath<String, String> { \.inQuotes }
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
