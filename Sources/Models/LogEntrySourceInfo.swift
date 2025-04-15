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

/// Additional context about a log entry's source.
///
/// `LogEntrySourceInfo` provides structured metadata about where a log entry originated:
///
/// ```swift
/// // File-based source information
/// let fileInfo = LogEntrySourceInfo.file(line: 42)
///
/// // SDK version information
/// let sdkInfo = LogEntrySourceInfo.sdk(version: "1.2.3")
///
/// // Error code information
/// let errorInfo = LogEntrySourceInfo.error(code: 404)
/// ```
///
/// This enum helps track the origin of log entries across different contexts:
/// - File locations for development debugging
/// - SDK versions for third-party integration issues
/// - Error codes for systematic error tracking
public enum LogEntrySourceInfo: Hashable, Sendable {
    /// Indicates the log originated from a specific line in a source file
    case file(line: Int)

    /// Indicates the log came from an SDK with a specific version
    case sdk(version: String)

    /// Indicates the log is associated with a specific error code
    case error(code: Int)
}
