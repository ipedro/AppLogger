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

public struct LogEntryContent: Hashable, LogConvertible {
    public var description: String
    public var output: String?
    public var userInfo: [String: String]

    public init(
        _ content: String,
        output: String? = .none,
        userInfo: [String: String]
    ) {
        self.description = content
        self.output = output
        self.userInfo = userInfo
    }

    public init(
        _ description: String,
        output: String? = .none,
        userInfo: Any?
    ) {
        self.description = description
        self.output = output

        switch Self.convert(userInfo) {
        case let .message(message) where output == .none:
            self.output = message
            self.userInfo = [:]
        case let .message(message):
            self.userInfo = [String(): message]
        case let .userInfo(dictionary):
            self.userInfo = dictionary
        }
    }

    func contains(_ searchQuery: String) -> Bool {
        if description.localizedCaseInsensitiveContains(searchQuery) { return true }
        if output?.localizedCaseInsensitiveContains(searchQuery) == true { return true }
        if userInfo.keys.joined().localizedCaseInsensitiveContains(searchQuery) { return true }
        if userInfo.values.joined().localizedCaseInsensitiveContains(searchQuery) { return true }
        return false
    }
}
