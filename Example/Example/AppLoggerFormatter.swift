import AppLogger
import Foundation
import XCGLogger
import UIKit

struct AppLoggerFormatter: LogFormatterProtocol {
    func format(logDetails: inout LogDetails, message: inout String) -> String {
        let logDetails = logDetails
        Task {
            await AppLogger.current.addLogEntry(
                LogEntry(
                    date: logDetails.date,
                    category: LogEntry.Category(logDetails.level.description),
                    source: {
                        if logDetails.fileName.isEmpty {
                            "XCGLogger"
                        } else {
                            LogEntry.Source(
                                (logDetails.fileName as NSString).lastPathComponent,
                                .file(line: logDetails.lineNumber)
                            )
                        }
                    }(),
                    content: LogEntry.Content(
                        function: logDetails.functionName,
                        message: logDetails.message,
                    ),
                    userInfo: logDetails.userInfo
                )
            )
        }
        return message
    }

    var debugDescription: String {
        "AppLoggerFormatter"
    }
}
