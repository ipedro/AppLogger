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

#if DEBUG

package typealias Mock = LogEntry.Mock

extension LogEntry {
    package enum Mock: Identifiable, Hashable, CaseIterable {
        case analytics
        case error
        case googleAnalytics
        case logger
        case socialLogin
        case warning
        
        package var id: Self { self }
        
        package var rawValue: LogEntry {
            switch self {
            case .analytics: analytics
            case .error: error
            case .googleAnalytics: googleAnalytics
            case .logger: logger
            case .socialLogin: socialLogin
            case .warning: warning
            }
        }
        
        private var logger: LogEntry {
            LogEntry(
                category: .debug,
                source: Source("MyWebView", .swift(lineNumber: 20)),
                content: .init(
                    "func didNavigate()",
                    output: "Navigation cancelled.",
                    userInfo: ["url": "https://google.com"]
                )
            )
        }
        
        private var googleAnalytics: LogEntry {
            LogEntry(
                category: Category("📈 Analytics"),
                source: Source("Google Analytics"),
                content: .init(
                    "tracked event",
                    userInfo: [
                        "customerID": "3864579",
                        "screen": "Home"
                    ]
                )
            )
        }
        
        private var socialLogin: LogEntry {
            LogEntry(
                category: Category("👔 Social Media"),
                source: Source("Facebook", .sdk(version: "12.2.1")),
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
        
        private var analytics: LogEntry {
            LogEntry(
                category: Category("📈 Analytics"),
                source: Source("Firebase", .sdk(version: "8.9.0")),
                content: .init(
                    "Open Screen: Home",
                    userInfo: [
                        "environment": "dev",
                        "event": "open home"
                    ]
                )
            )
        }
        
        private var error: LogEntry {
            LogEntry(
                category: .error,
                source: Source(
                    "Alamofire.AFError",
                    .error(code: 19)
                ),
                content: .init(
                    "Couldn't load url",
                    userInfo: [:]
                )
            )
        }
        
        private var warning: LogEntry {
            LogEntry(
                category: .warning,
                source: Source("I'm a warning"),
                content: .init(
                    "Couldn't find user_id",
                    userInfo: [:]
                )
            )
        }
    }
}
#endif
