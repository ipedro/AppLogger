import Data
import UIKit

/// A centralized logging actor for handling asynchronous log entry management and UI presentation.
public actor VisualLogger {
    /// Underlying datastore that records log entries.
    private let dataStore = DataStore()

    /// The current active coordinator responsible for presenting the log interface.
    private var coordinator: Coordinator?

    /// Shared instance of `VisualLogger` for global accessibility.
    public static let current = VisualLogger()

    /// Adds a log entry to the underlying data store.
    ///
    /// This method offloads the logging operation to a background task, ensuring that the
    /// user interface remains responsive. It uses Swift concurrency to perform asynchronous
    /// writes without blocking the main thread.
    ///
    /// - Parameter log: A `LogEntry` instance representing the event or message to be logged.
    public nonisolated func addLogEntry(_ log: LogEntry) {
        Task {
            await dataStore.addLogEntry(log)
        }
    }

    /// Presents the logging interface modally.
    ///
    /// Before initiating presentation, this method checks that no coordinator is already active.
    /// It then creates a data observer from the data store and configures a new `Coordinator` instance
    /// to manage the logging UI. The asynchronous presentation allows for a smooth and dynamic
    /// user experience.
    ///
    /// - Parameters:
    ///   - animated: A Boolean value indicating whether the presentation should be animated. Defaults to `true`.
    ///   - configuration: An `VisualLoggerConfiguration` instance that provides custom presentation settings.
    ///     Defaults to a new instance of `VisualLoggerConfiguration`.
    ///   - completion: An optional closure executed after the presentation completes.
    ///
    /// - Warning: If a coordinator is already active, the method exits without re-presenting the UI.
    public func present(
        animated: Bool = true,
        configuration: VisualLoggerConfiguration = .init(),
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

    /// Dismisses the current logging interface.
    ///
    /// This helper method resets the active coordinator and, if a view controller is provided,
    /// dismisses it on the main actor to ensure proper UI thread management.
    ///
    /// - Parameter viewController: The `UIViewController` instance to dismiss. If `nil`, only the coordinator state is reset.
    private func dismiss(viewController: UIViewController?) {
        coordinator = nil
        if let viewController {
            Task { @MainActor in
                viewController.dismiss(animated: true)
            }
        }
    }
}
