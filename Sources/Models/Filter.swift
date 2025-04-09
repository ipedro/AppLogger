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

package struct Filter: CustomStringConvertible, Identifiable, Hashable {
    package var id: String { query }
    package var query: String
    package var description: String
    
    package init(query: String, description: String? = nil) {
        self.query = query
        self.description = description ?? query
    }
    
    package func hash(into hasher: inout Hasher) {
        hasher.combine(query)
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
        self.description = value
    }
}

// MARK: - Filter Convertible

package protocol FilterConvertible {
    var filter: Filter { get }
}

// MARK: - Filterable

package protocol Filterable {
    static var filterable: KeyPath<Self, String> { get }
    static var filterableOptional: KeyPath<Self, String?>? { get }
}

package extension Filterable {
    static var filterableOptional: KeyPath<Self, String?>? { nil }
    
    func matches(_ filter: Filter) -> Bool {
        if self[keyPath: Self.filterable].localizedCaseInsensitiveContains(filter.query) {
            return true
        }
        
        if let keyPath = Self.filterableOptional {
            if self[keyPath: keyPath]?.localizedCaseInsensitiveContains(filter.query) == true {
                return true
            }
        }
        return false
    }
}
