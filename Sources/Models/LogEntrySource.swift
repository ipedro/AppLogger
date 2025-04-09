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

import struct SwiftUICore.Color

package typealias Source = LogEntry.Source

public extension LogEntry {
    struct Source: LogEntrySource, Hashable, Sendable {
        public let emoji: Character?
        public let name: String
        public let info: SourceInfo?
        
        public init(
            _ name: String,
            _ info: SourceInfo? = .none
        ) {
            self.emoji = nil
            self.name = name
            self.info = info
        }
        
        public init(
            _ emoji: Character,
            _ name: String,
            _ info: SourceInfo? = .none
        ) {
            self.emoji = emoji
            self.name = name
            self.info = info
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
    package var filter: Filter {
        Filter(query: name, description: description)
    }
}

extension LogEntry.Source: Filterable {
    package func matches(_ filter: Filter) -> Bool {
        description.localizedLowercase.contains(filter.query.localizedLowercase)
    }
}
