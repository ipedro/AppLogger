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
