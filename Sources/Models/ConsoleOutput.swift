// MIT License
//
// Copyright (c) 2025 Pedro Almeida
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

package enum ConsoleOutput: @unchecked /* but safe */ Sendable {
    case logEntry(LogEntry)
    case text(String)
    case userInfo([String: Any])

    package init?(_ value: String) {
        let text = value.trimmingCharacters(in: .whitespacesAndNewlines)

        if let log = OSLogRecord.parse(from: value) {
            self = .logEntry(log.asLogEntry())
        } else if let userInfo = Self.parse(value) {
            self = .userInfo(userInfo)
        } else if let userInfo = Self.parse(Self.sanitizeJSONCandidate(value)) {
            self = .userInfo(userInfo)
        } else if !text.isEmpty {
            self = .text(value)
        } else {
            return nil
        }
    }

    private static func parse(_ s: String) -> [String: AnyHashable]? {
        guard let data = s.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: AnyHashable]
    }

    /// Attempts to coerce an Apple‑style dictionary debug print into valid JSON.
    /// * Converts the leading `[` and trailing `]` to `{` / `}` (only once each).
    /// * Wraps tuple‑style values like `(0.0, 0.0, 393.0, 852.0)` in quotes
    ///   so they survive JSON parsing.
    static func sanitizeJSONCandidate(_ text: String) -> String {
        var result = text

        // 1. Replace the first "[" with "{" and the last "]" with "}".
        if result.hasPrefix("[") {
            result.replaceSubrange(result.startIndex ... result.startIndex, with: "{")
        }
        if result.hasSuffix("]") {
            let last = result.index(before: result.endIndex)
            result.replaceSubrange(last ... last, with: "}")
        }

        // 2. Quote tuple‑style values:  key: (a, b, c)  → key: "(a, b, c)"
        let pattern = #"(:\s*)\(([^\)]*)\)"#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(result.startIndex ..< result.endIndex, in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: range,
                withTemplate: #"$1\"($2)\""#
            )
        }

        return result
    }
}
