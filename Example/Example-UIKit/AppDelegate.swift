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

import UIKit
import VisualLogger
@preconcurrency import XCGLogger

let log = XCGLogger.default

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    override init() {
        super.init()
        log.formatters = [VisualLoggerFormatter()]
        log.setup(
            level: .verbose,
            showLogIdentifier: false,
            showFunctionName: true,
            showThreadName: false,
            showLevel: true,
            showFileNames: true,
            showLineNumbers: true,
            showDate: true,
            writeToFile: .none,
            fileLevel: nil
        )
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        log.verbose(
            userInfo: [
                "state": application.applicationState.debugDescription,
                "badge number": String(application.applicationIconBadgeNumber),
            ]
        )
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        log.verbose(connectingSceneSession)
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        log.verbose(sceneSessions)
    }
}

extension UIApplication.State: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .active:
            "Active"
        case .inactive:
            "Inactive"
        case .background:
            "Background"
        default:
            "Default"
        }
    }
}
