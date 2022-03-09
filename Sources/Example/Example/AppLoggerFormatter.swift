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

import AppLogger
import Foundation
import XCGLogger

struct AppLoggerFormatter: LogFormatterProtocol {
    let appLogger: AppLogging

    func format(logDetails: inout LogDetails, message: inout String) -> String {
        appLogger.addLogEntry(
            .init(
                category: .init(logDetails.level),
                source: .init(
                    name: String(logDetails.fileName.split(separator: ".").first!.split(separator: "/").last!),
                    info: .swift(lineNumber: logDetails.lineNumber)
                ),
                content: .init(
                    logDetails.functionName.last == ")" ? "func \(logDetails.functionName)" : "var \(logDetails.functionName)",
                    output: logDetails.message,
                    userInfo: logDetails.userInfo.isEmpty ? .none : logDetails.userInfo
                )
            )
        )
        return message
    }

    var debugDescription: String {
        String(describing: appLogger)
    }
}

private extension LogEntryCategory {
    init(_ level: XCGLogger.Level) {
        switch level {
        case .verbose: self = .verbose
        case .debug: self = .debug
        case .info: self = .info
        case .notice: self = .notice
        case .warning: self = .warning
        case .error: self = .error
        case .severe: self = .severe
        case .alert: self = .alert
        case .emergency: self = .emergency
        case .none: self = .init("None")
        }
    }
}
