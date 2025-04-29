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

/// Strongly-typed view of one “OSLOG-…” line.
package struct OSLogRecord: Sendable {
    // --- fixed header -------------------------------------------------------
    package let id: UUID
    package let severity: UInt8 // syslog numeric level (0-7)
    package let subsystemCode: UInt8 // rarely useful but present («80» in sample)
    package let facility: Character // «L»
    package let typeCode: String // «e», «f», or numeric like «10»

    // --- dynamic payload inside {…} ----------------------------------------
    package let timestamp: Date? // derived from  t:<epoch>
    package let type: String? // «Error» in sample
    package let subsystem: String? // «com.apple.UIKit»
    package let category: String? // «LayoutConstraints»
    package let offset: UInt64? // hex → UInt64
    package let imageUUID: UUID? // imgUUID
    package let imagePath: String? // imgPath
    package let lines: Int? // lines:20

    // --- free-form text that follows the tab -------------------------------
    package let message: String

    // -----------------------------------------------------------------------
    /// Returns `nil` when `raw` is not an OSLog entry.
    package static func parse(from raw: String) -> OSLogRecord? {
        // Trim leading whitespace/newlines
        let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. Quick reject
        guard line.hasPrefix("OSLOG-") else { return nil }

        // 2. Capture header + brace block + message
        let pattern = #"OSLOG-([A-F0-9\-]+)\s+(\d+)\s+(\d+)\s+([A-Z])\s+([A-Za-z0-9]+)\s+(\{.*?\})\t(.*)"#

        guard
            let regex = try? NSRegularExpression(
                pattern: pattern,
                options: [.dotMatchesLineSeparators]
            ),
            let m = regex.firstMatch(
                in: line,
                range: NSRange(line.startIndex..., in: line)
            )
        else {
            return nil
        }

        func g(_ index: Int) -> String {
            String(line[Range(m.range(at: index), in: line)!])
        }

        guard
            let uuid = UUID(uuidString: g(1)),
            let sev = UInt8(g(2)),
            let subCode = UInt8(g(3)),
            let fac = g(4).first
        else {
            return nil
        }

        let typeC = g(5)

        // 3. Extract key/value pairs from the { … } block --------------------
        let braceBlock = g(6).dropFirst().dropLast() // remove outer braces

        func value(for key: String) -> String? {
            let keyPat = #"\#(key):([^,}]+)"#
            let r = try? NSRegularExpression(pattern: keyPat)
            guard
                let match = r?.firstMatch(
                    in: String(braceBlock),
                    range: NSRange(braceBlock.startIndex..., in: braceBlock)
                ),
                match.numberOfRanges == 2
            else {
                return nil
            }
            return String(braceBlock[Range(match.range(at: 1), in: braceBlock)!])
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        }

        let tsString = value(for: "t")
        let timestamp: Date? = tsString.flatMap { Double($0).map(Date.init(timeIntervalSince1970:)) }

        let offset: UInt64? = {
            guard
                let hex = value(for: "offset")?.replacingOccurrences(of: "0x", with: ""),
                let v = UInt64(hex, radix: 16)
            else {
                return nil
            }
            return v
        }()

        let linesInt = value(for: "lines").flatMap(Int.init)

        let record = OSLogRecord(
            id: uuid,
            severity: sev,
            subsystemCode: subCode,
            facility: fac,
            typeCode: typeC,
            timestamp: timestamp,
            type: value(for: "type"),
            subsystem: value(for: "subsystem"),
            category: value(for: "category"),
            offset: offset,
            imageUUID: value(for: "imgUUID").flatMap(UUID.init(uuidString:)),
            imagePath: value(for: "imgPath"),
            lines: linesInt,
            message: g(7).trimmingCharacters(in: .whitespacesAndNewlines)
        )
        return record
    }

    package func asLogEntry() -> LogEntry {
        LogEntry(
            date: timestamp ?? Date(),
            category: {
                if let logType = type {
                    if let category = LogEntryCategory.Default(rawValue: logType)?.category() {
                        category
                    } else {
                        LogEntryCategory(logType)
                    }
                } else {
                    .warning
                }
            }(),
            source: {
                if let logSubsystem = subsystem {
                    LogEntrySource(logSubsystem)
                } else {
                    "System"
                }
            }(),
            content: LogEntryContent(
                title: category ?? "",
                subtitle: message
            )
        )
    }
}
