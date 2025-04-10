//  Copyright (c) 2022 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import struct Foundation.UUID

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
// MARK: - Filterable

package protocol Filterable {
    static var filterQuery: KeyPath<Self, String> { get }
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
            query: self[keyPath: Self.filterQuery],
            displayName: self[keyPath: Self.filterDisplayName]
        )
    }
}

// MARK: - Helpers

extension String: FilterConvertible {
    package static var filterKind: Filter.Kind { .all }
    package static var filterDisplayName: KeyPath<String, String> { \.self }
    package static var filterQuery: KeyPath<String, String> { \.self }
}


package extension Filterable {
    static var filterCriteriaOptional: KeyPath<Self, String?>? { nil }
    
    func matches(_ filter: Filter) -> Bool {
        let value = self[keyPath: Self.filterQuery]
        if value.localizedCaseInsensitiveContains(filter.query) {
            //print("Filter \(filter.kind):", filter.query, "–", "Match:", value)
            return true
        }
        
        if let keyPath = Self.filterCriteriaOptional, let optionalValue = self[keyPath: keyPath] {
            if optionalValue.localizedCaseInsensitiveContains(filter.query) {
                //print("Filter \(filter.kind):", filter.query, "–", "Match:", optionalValue)
                return true
            }
        }
        return false
    }
}
