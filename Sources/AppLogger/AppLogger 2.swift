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

import SwiftUI
import struct Models.LogEntry
import Data

public actor AppLogger {
    static let sharedInstance = AppLogger()

    let dataStore = DataStore()
    
    /// Adds a log entry to the DataStore.
    ///
    /// - Parameter logEntry: The log entry to add.
    /// - Returns: A Boolean indicating whether the log entry was successfully added. Returns false if the log entry's ID already exists.
    func addLogEntry(_ log: LogEntry) async {
        await dataStore.addLogEntry(log)
    }
}

final class AppLoggerPresenter {
    @MainActor var window: UIWindow? {
        UIApplication.shared.windows.filter(\.isKeyWindow).first
    }
    
    let observer = DataStoreObserver()
    
    @MainActor func present() {
        guard let window else { return }
        guard let rootViewController = window.rootViewController else { return }
        
        rootViewController.present(UIHostingController(rootView: Logger), animated: true)
    }
}
