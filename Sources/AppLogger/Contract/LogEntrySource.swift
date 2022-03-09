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

public struct LogEntrySource: Hashable, AppLoggerSourceProtocol {
    public var emoji: Character?
    public var debugName: String
    public var debugColor: UIColor?
    public var debugInfo: AppLoggerSourceInfo?

    public init(
        _ emoji: Character? = .none,
        name: String,
        color: UIColor? = .none,
        info: AppLoggerSourceInfo? = .none
    ) {
        self.emoji = emoji
        self.debugName = name
        self.debugColor = color
        self.debugInfo = info
    }

    var displayName: String {
        guard let emoji = emoji else { return debugName }
        return "\(emoji) \(debugName)"
    }

    public static func == (lhs: LogEntrySource, rhs: LogEntrySource) -> Bool {
        lhs.debugName == rhs.debugName &&
        lhs.debugColor == rhs.debugColor
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(debugName)
        hasher.combine(debugColor)
    }
}

