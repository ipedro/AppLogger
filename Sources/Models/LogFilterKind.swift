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
