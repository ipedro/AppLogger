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

import Combine
import Foundation

/// Redirects `stdout` and `stderr` into a Combine publisher.
/// The underlying pipes remain open for as long as the instance
/// is retained and are restored automatically on de‑initialisation.
package final class ConsolePipe {
    // MARK: - Private storage

    private lazy var inputPipe = Pipe()
    private lazy var outputPipe = Pipe()

    /// Original file descriptors so we can restore them on teardown.
    private let originalStdout: Int32
    private let originalStderr: Int32

    // MARK: - Public API

    /// Creates a new console pipe and begins streaming immediately.
    package init?() {
        originalStdout = dup(STDOUT_FILENO)
        originalStderr = dup(STDERR_FILENO)

        guard originalStdout != -1, originalStderr != -1 else {
            return nil
        }
    }

    enum Error: Swift.Error {
        case failedToCaptureConsoleOutput
    }

    package typealias Handler = @Sendable (ConsoleOutput) -> Void

    package func callAsFunction(handler: @escaping Handler) throws {
        #if !targetEnvironment(simulator)
            setvbuf(stdout, nil, _IONBF, 0)
        #endif

        // from documentation
        // dup2() makes newfd (new file descriptor) be the copy of oldfd (old file descriptor), closing newfd first if necessary.

        // here we are copying the STDOUT file descriptor into our output pipe's file descriptor
        // this is so we can write the strings back to STDOUT, so it can show up on the xcode console
        guard
            dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor) != -1
        else {
            throw Error.failedToCaptureConsoleOutput
        }

        // In this case, the newFileDescriptor is the pipe's file descriptor and the old file descriptor is STDOUT_FILENO and STDERR_FILENO
        guard
            dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO) != -1,
            dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO) != -1
        else {
            throw Error.failedToCaptureConsoleOutput
        }

        inputPipe.fileHandleForReading.readabilityHandler = { [weak outputPipe] pipeReadHandle in
            do {
                let data = pipeReadHandle.availableData

                guard let str = String(data: data, encoding: .utf8) else {
                    return
                }

                if let output = ConsoleOutput(str) {
                    handler(output)
                }

                // write the data back into the output pipe. the output pipe's write file descriptor points to STDOUT. this allows the logs to show up on the xcode console
                outputPipe?.fileHandleForWriting.write(data)
            }
        }

        print("Registered console logging pipe.")
    }

    deinit {
        // 1. Stop asynchronous callbacks.
        inputPipe.fileHandleForReading.readabilityHandler = nil

        // 2. Restore the original stdio so future sessions start clean.
        dup2(originalStdout, STDOUT_FILENO)
        dup2(originalStderr, STDERR_FILENO)
        close(originalStdout)
        close(originalStderr)

        // 3. Close our pipe ends.
        inputPipe.fileHandleForReading.closeFile()
        inputPipe.fileHandleForWriting.closeFile()
        outputPipe.fileHandleForWriting.closeFile()
    }
}

package struct ConsoleOutput: @unchecked /* but safe */ Sendable {
    package let text: String?
    package let userInfo: [String: Any]?

    init?(_ value: String) {
        let text = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else {
            return nil
        }

        userInfo = {
            // Try the raw message first; if it fails, apply sanitisation.
            if let obj = Self.parse(text) { return obj }

            let sanitized = Self.sanitizeJSONCandidate(text)
            // Attempt to fix common non‑JSON constructs (CGRect tuples, etc.)
            let json = Self.parse(sanitized)
            return json
        }()

        self.text = userInfo == nil ? text : nil
    }

    private static func parse(_ s: String) -> [String: AnyHashable]? {
        guard let data = s.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: AnyHashable]
    }

    /// Attempts to coerce an Apple‑style dictionary debug print into valid JSON.
    /// * Converts the leading `[` and trailing `]` to `{` / `}` (only once each).
    /// * Wraps tuple‑style values like `(0.0, 0.0, 393.0, 852.0)` in quotes
    ///   so they survive JSON parsing.
    private static func sanitizeJSONCandidate(_ text: String) -> String {
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
