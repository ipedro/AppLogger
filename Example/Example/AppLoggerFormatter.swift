import AppLogger
import Foundation
import UIKit
import XCGLogger

struct AppLoggerFormatter: LogFormatterProtocol {
    func format(logDetails: inout LogDetails, message: inout String) -> String {
        let logDetails = logDetails
        AppLogger.current.addLogEntry(
            LogEntry(
                date: logDetails.date,
                category: LogEntryCategory(logDetails.level.description),
                source: {
                    if logDetails.fileName.isEmpty {
                        "XCGLogger"
                    } else {
                        LogEntrySource(
                            (logDetails.fileName as NSString).lastPathComponent,
                            .file(line: logDetails.lineNumber)
                        )
                    }
                }(),
                content: LogEntryContent(
                    function: logDetails.functionName,
                    message: logDetails.message,
                ),
                userInfo: logDetails.userInfo
            )
        )
        return message
    }

    var debugDescription: String {
        "AppLoggerFormatter"
    }
}
