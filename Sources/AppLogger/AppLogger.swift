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

import class Data.DataObserver
import class Data.DataStore
import class Data.ColorStore
import class UIKit.UIViewController

public actor AppLogger {
    private let dataStore = DataStore()
    
    private var coordinator: Coordinator?

    public static let current = AppLogger()
    
    /// Adds a log entry to the DataStore.
    ///
    /// - Parameter logEntry: The log entry to add.
    /// - Returns: A Boolean indicating whether the log entry was successfully added. Returns false if the log entry's ID already exists.
    @discardableResult
    public func addLogEntry(_ log: LogEntry) async -> Bool {
        await dataStore.addLogEntry(log)
    }
    
    public func present(
        animated: Bool = true,
        configuration: AppLoggerConfiguration = .init(),
        completion: (@Sendable () -> Void)? = nil
    ) async {
        guard coordinator == nil else {
            return
        }
        
        let observer = await dataStore.makeObserver()
        
        let coordinator = await Coordinator(
            dataObserver: observer,
            configuration: configuration,
            dismiss: dismiss(viewController:)
        )
        
        self.coordinator = coordinator
        
        await coordinator.present(
            animated: animated,
            completion: completion
        )
    }
    
    private func dismiss(viewController: UIViewController?) {
        coordinator = nil
        if let viewController {
            Task { @MainActor in
                viewController.dismiss(animated: true)
            }
        }
    }
}
