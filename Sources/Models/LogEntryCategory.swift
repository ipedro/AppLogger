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

import Foundation

public extension LogEntry.Category {
    static let verbose = Self("🗯", "Verbose")
    static let debug = Self("🔹", "Debug")
    static let info = Self("ℹ️", "Info")
    static let notice = Self("✳️", "Notice")
    static let warning = Self("⚠️", "Warning")
    static let error = Self("‼️", "Error")
    static let severe = Self("💣", "Severe")
    static let alert = Self("🛑", "Alert")
    static let emergency = Self("🚨", "Emergency")
}

package typealias Category = LogEntry.Category

public extension LogEntry {
    /// A structure that represents a log entry category with an optional emoji and a debug name.
    ///
    /// It provides computed properties for representing the emoji as a string and for creating a display name by combining the emoji (if available) with the debug name.
    struct Category: CustomStringConvertible, Sendable {
        /// An optional emoji associated with this log entry category.
        public let emoji: Character?
        /// A string identifier used for debugging and identifying the log entry category.
        public let name: String
        
        /// Initializes a new log entry category with the given debug name.
        ///
        /// - Parameter name: A string identifier for the category.
        public init(_ name: String) {
            self.emoji = nil
            self.name = name
        }
        
        /// Initializes a new log entry category with the given emoji and debug name.
        ///
        /// - Parameters:
        ///   - emoji: An emoji representing the category.
        ///   - name: A string identifier for the category.
        public init(_ emoji: Character, _ name: String) {
            self.emoji = emoji
            self.name = name
        }
        
        /// Returns a display name that includes the emoji (if available) followed by the debug name.
        public var description: String {
            if let emoji {
                "\(emoji) \(name)"
            } else {
                name
            }
        }
    }
}

extension LogEntry.Category: Filterable {
    package func matches(_ filter: Filter) -> Bool {
        description.localizedLowercase.contains(filter.query.localizedLowercase)
    }
}
