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

public struct LogEntryCategory: Hashable {
    public let emoji: Character?
    public let debugName: String

    public var emojiString: String? {
        guard let emoji = emoji else { return .none }
        return String(emoji)
    }

    var displayName: String {
        guard let emoji = emoji else { return debugName }
        return "\(emoji) \(debugName)"
    }

    public init(_ debugName: String) {
        self.emoji = nil
        self.debugName = debugName
    }

    public init(_ emoji: Character, _ debugName: String) {
        self.emoji = emoji
        self.debugName = debugName
    }
}

public extension LogEntryCategory {
    static let verbose: LogEntryCategory = .init("🗯", "Verbose")
    static let debug: LogEntryCategory = .init("🔹", "Debug")
    static let info: LogEntryCategory = .init("ℹ️", "Info")
    static let notice: LogEntryCategory = .init("✳️", "Notice")
    static let warning: LogEntryCategory = .init("⚠️", "Warning")
    static let error: LogEntryCategory = .init("‼️", "Error")
    static let severe: LogEntryCategory = .init("💣", "Severe")
    static let alert: LogEntryCategory = .init("🛑", "Alert")
    static let emergency: LogEntryCategory = .init("🚨", "Emergency")
}
