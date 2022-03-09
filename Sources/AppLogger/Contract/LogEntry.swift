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
import UIKit

public struct LogEntry: Hashable {
    public let createdAt = Date()

    public var source: LogEntrySource

    public var content: LogEntryContent

    public var category: LogEntryCategory

    public init(
        category: LogEntryCategory,
        source: LogEntrySource,
        content: LogEntryContent
    ) {
        self.source = source
        self.category = category
        self.content = content
    }

    func contains(_ searchQuery: String) -> Bool {
        if category.debugName.contains(searchQuery) { return true }
        if source.debugName.contains(searchQuery) { return true }
        return content.contains(searchQuery)
    }
}

// MARK: - Comparable

extension LogEntry: Comparable {
    public static func < (lhs: LogEntry, rhs: LogEntry) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}

// MARK: - Private Helpers

private extension Optional where Wrapped == String {
    func contains(_ string: String) -> Bool {
        switch self {
        case .none: return false
        case let .some(wrapped): return wrapped.contains(string)
        }
    }
}

private extension String {
    func contains(_ string: String) -> Bool {
        range(of: string, options: .caseInsensitive) != nil
    }
}
