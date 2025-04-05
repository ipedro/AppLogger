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

enum AppLoggerEntryMock {
    static var allCases: [LogEntry] = [
        AppLoggerEntryMock.googleAnalytics,
        AppLoggerEntryMock.socialLogin,
        AppLoggerEntryMock.analytics,
        AppLoggerEntryMock.error,
        AppLoggerEntryMock.warning,
        AppLoggerEntryMock.logger
    ]

    static var logger: LogEntry {
        LogEntry(
            category: .debug,
            source: .init(
                name: "MyWebView",
                info: .swift(lineNumber: 20)
            ),
            content: .init(
                "func didNavigate()",
                output: "Navigation cancelled.",
                userInfo: ["url": "https://google.com"]
            )
        )
    }

    static var googleAnalytics: LogEntry {
        LogEntry(
            category: .init("📈 Analytics"),
            source: .init(
                name: "Google Analytics",
                info: .none
            ),
            content: .init(
                "tracked event",
                userInfo: [
                    "customerID": "3864579",
                    "screen": "Home"
                ]
            )
        )
    }

    static var socialLogin: LogEntry {
        LogEntry(
            category: .init("👔 Social Media"),
            source: .init(
                name: "Facebook",
                info: .sdk(version: "12.2.1")
            ),
            content: .init(
                "Any Social Login",
                userInfo: [
                        "custom_event": "1",
                        "environment": "dev",
                        "screenName": "Home",
                        "user_id": "3864579"
                ]
            )
        )
    }

    static var analytics: LogEntry {
        LogEntry(
            category: .init("📈 Analytics"),
            source: .init(
                name: "Firebase",
                info: .sdk(version: "8.9.0")
            ),
            content: .init(
                "Open Screen: Home",
                userInfo: [
                    "environment": "dev",
                    "event": "open home"
                ]
            )
        )
    }

    static var error: LogEntry {
        LogEntry(
            category: .error,
            source: .init(
                name: "Alamofire.AFError",
                color: .systemRed,
                info: .error(code: 19)
            ),
            content: .init(
                "Couldn't load url",
                userInfo: [:]
            )
        )
    }

    static var warning: LogEntry {
        LogEntry(
            category: .warning,
            source: .init(
                name: "I'm a warning",
                color: .systemOrange,
                info: .none
            ),
            content: .init(
                "Couldn't find user_id",
                userInfo: [:]
            )
        )
    }
}
