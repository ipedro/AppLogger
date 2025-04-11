import Foundation

package struct Filter: Hashable {
    package let kind: Kind
    package let query: String
    package let displayName: String
    
    init(_ kind: Kind, query: String, displayName: String) {
        self.query = query
        self.kind = kind
        self.displayName = displayName
    }
}

extension Filter {
    package struct Kind: CustomStringConvertible, Hashable, OptionSet {
        package let rawValue: Int8
        
        package var description: String {
            var components = [String]()
            if self.contains(.source) { components.append("source") }
            if self.contains(.category) { components.append("category") }
            if self.contains(.content) { components.append("content") }
            if self.contains(.userInfo) { components.append("userInfo") }
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

extension Filter: Comparable {
    package static func < (lhs: Filter, rhs: Filter) -> Bool {
        lhs.query.localizedStandardCompare(rhs.query) == .orderedAscending
    }
}

extension Filter: ExpressibleByStringLiteral {
    package init(stringLiteral value: String) {
        self.query = value
        self.displayName = value
        self.kind = .all
    }
}

package extension Collection where Element == Filter {
    func sort(by selection: Set<Filter>) -> [Filter] {
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

package protocol Filterable {
    static var filterCriteria: KeyPath<Self, String> { get }
    static var filterCriteriaOptional: KeyPath<Self, String?>? { get }
}

// MARK: - Filter Convertible

package protocol FilterConvertible: Filterable {
    static var filterDisplayName: KeyPath<Self, String> { get }
    static var filterKind: Filter.Kind { get }
}

package extension FilterConvertible {
    var filter: Filter {
        Filter(
            Self.filterKind,
            query: self[keyPath: Self.filterCriteria],
            displayName: self[keyPath: Self.filterDisplayName]
        )
    }
}

// MARK: - Helpers

extension String: FilterConvertible {
    package static var filterKind: Filter.Kind { .all }
    package static var filterDisplayName: KeyPath<String, String> { \.self }
    package static var filterCriteria: KeyPath<String, String> { \.self }
    package static var filterCriteriaOptional: KeyPath<String, String?>? { nil }
}


package extension Filterable {
    func matches(_ filter: Filter) -> Bool {
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
