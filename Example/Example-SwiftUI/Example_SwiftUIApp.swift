//
//  Example_SwiftUIApp.swift
//  Example-SwiftUI
//
//  Created by Pedro Almeida on 14.04.25.
//

import SwiftUI
import XCGLogger

let log = XCGLogger.default

@main
struct Example_SwiftUIApp: App {
    init() {
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

    var body: some Scene {
        WindowGroup {
            ContentView().task {
                log.info(">>> App started <<<", userInfo: ["app": self])
            }
        }
    }
}
