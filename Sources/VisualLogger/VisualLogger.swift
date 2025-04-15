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


import Data
import UIKit

// MARK: - Public APIs

public extension VisualLogger {
    /// Enqueues a visual logger action for later use.
    ///
    /// This method asynchronously adds the specified visual logger action to the underlying data store.
    /// It is designed to allow you to attach interactive actions within the visual logging interface.
    ///
    /// - Parameter action: A `VisualLoggerAction` instance representing the action to be added.
    ///
    /// **Example:**
    /// ```swift
    /// let clearLogsAction = VisualLoggerAction(title: "Clear Logs") {
    ///     // Implementation to clear logs
    /// }
    /// VisualLogger.addAction(clearLogsAction)
    /// ```
    static func addAction(_ action: VisualLoggerAction) {
        Task {
            await current.dataStore.addAction(action)
        }
    }

    /// Removes a visual logger action.
    ///
    /// This method asynchronously removes the specified visual logger action from the underlying data store,
    /// ensuring that the action is no longer available within the visual logging interface.
    ///
    /// - Parameter action: A `VisualLoggerAction` instance representing the action to be removed.
    ///
    /// **Example:**
    /// ```swift
    /// let clearLogsAction = VisualLoggerAction(title: "Clear Logs")
    /// VisualLogger.removeAction(clearLogsAction)
    /// ```
    static func removeAction(_ action: VisualLoggerAction) {
        Task {
            await current.dataStore.removeAction(action)
        }
    }

    /// Adds a log entry to the underlying data store.
    ///
    /// This method offloads the logging operation to a background task, ensuring that the
    /// user interface remains responsive. It uses Swift concurrency to perform asynchronous
    /// writes without blocking the main thread.
    ///
    /// - Parameter log: A `LogEntry` instance representing the event or message to be logged.
    static func addLogEntry(_ log: @autoclosure @escaping @Sendable () -> LogEntry) {
        Task {
            await current.dataStore.addLogEntry(log())
        }
    }

    /// Presents the logging interface modally on a sheet.
    ///
    /// - Parameters:
    ///   - animated: A Boolean value indicating whether the presentation should be animated. Defaults to `true`.
    ///   - configuration: A `VisualLoggerConfiguration` instance that provides custom presentation settings.
    ///     Defaults to a new instance of `VisualLoggerConfiguration`.
    ///   - sourceView: The view that the sheet centers itself over.
    ///   - completion: An optional closure executed after the presentation completes.
    ///
    /// > Note: If there is a presentation already active, the method exits without re-presenting the UI.
    ///
    /// > Tip: To customize the sheet’s position, set a view within the view hierarchy
    /// of the presenting view controller as the `sourceView` of the sheet.
    /// The sheet attempts to visually center itself over this view. The system
    /// only positions the sheet within system-defined margins.
    static func present(
        animated: Bool = true,
        configuration: VisualLoggerConfiguration = .init(),
        from sourceView: UIView? = nil,
        completion: (@Sendable () -> Void)? = nil
    ) {
        Task {
            await current.present(
                animated: animated,
                configuration: configuration,
                sourceView: sourceView,
                completion: completion
            )
        }
    }
}

// MARK: - Implementation

/// A centralized logging actor for handling asynchronous log entry management and UI presentation.
public actor VisualLogger: LogEntrySourceProtocol {
    /// Underlying datastore that records log entries.
    private let dataStore = DataStore()

    /// The current active coordinator responsible for presenting the log interface.
    private var coordinator: Coordinator?

    /// Shared instance of `VisualLogger`.
    static let current = VisualLogger()

    func makeDataObserver() async -> DataObserver {
        await dataStore.makeObserver()
    }

    private func present(
        animated: Bool,
        configuration: VisualLoggerConfiguration,
        sourceView: UIView?,
        completion: (@Sendable () -> Void)?
    ) async {
        guard coordinator == nil else {
            return await dataStore.addLogEntry(
                LogEntry(
                    category: .warning,
                    source: self,
                    content: LogEntryContent(
                        function: #function,
                        message: "VisualLogger already presented."
                    )
                )
            )
        }

        let observer = await dataStore.makeObserver()

        let coordinator = await Coordinator(
            dataObserver: observer,
            configuration: configuration,
            dismiss: { [unowned self] in
                await dismiss()
            }
        )

        do {
            try await coordinator.present(
                animated: animated,
                sourceView: sourceView,
                completion: completion
            )

            self.coordinator = coordinator
        } catch {
            await dataStore.addLogEntry(
                LogEntry(
                    category: .error,
                    source: self,
                    content: LogEntryContent(
                        function: #function,
                        message: error.localizedDescription
                    )
                )
            )
        }
    }

    /// Dismisses the current logging interface without external parameters.
    ///
    /// This method is invoked internally to reset the active coordinator and clear the log interface state.
    ///
    /// - Note: This method should not be called directly outside of the VisualLogger context.
    private func dismiss() async {
        coordinator = nil
    }
}
