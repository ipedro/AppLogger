import Data
import UIKit

/// A centralized logging actor for handling asynchronous log entry management and UI presentation.
public actor VisualLogger: LogEntrySourceProtocol {
    /// Underlying datastore that records log entries.
    private let dataStore = DataStore()

    /// The current active coordinator responsible for presenting the log interface.
    private var coordinator: Coordinator?

    /// Shared instance of `VisualLogger` for global accessibility.
    public static let current = VisualLogger()

    public nonisolated func addAction(_ action: VisualLoggerAction) {
        Task {
            await dataStore.addAction(action)
        }
    }

    public nonisolated func removeAction(_ action: VisualLoggerAction) {
        Task {
            await dataStore.removeAction(action)
        }
    }

    /// Adds a log entry to the underlying data store.
    ///
    /// This method offloads the logging operation to a background task, ensuring that the
    /// user interface remains responsive. It uses Swift concurrency to perform asynchronous
    /// writes without blocking the main thread.
    ///
    /// - Parameter log: A `LogEntry` instance representing the event or message to be logged.
    public nonisolated func addLogEntry(_ log: @autoclosure @escaping @Sendable () -> LogEntry) {
        Task {
            await dataStore.addLogEntry(log())
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
    public nonisolated func present(
        animated: Bool = true,
        configuration: VisualLoggerConfiguration = .init(),
        from sourceView: UIView? = nil,
        completion: (@Sendable () -> Void)? = nil
    ) {
        Task {
            await _present(
                animated: animated,
                configuration: configuration,
                sourceView: sourceView,
                completion: completion
            )
        }
    }

    func makeDataObserver() async -> DataObserver {
        await dataStore.makeObserver()
    }

    private func _present(
        animated: Bool,
        configuration: VisualLoggerConfiguration,
        sourceView: UIView?,
        completion: (@Sendable () -> Void)?,
        function: String = #function
    ) async {
        guard coordinator == nil else {
            return addLogEntry(
                LogEntry(
                    category: .warning,
                    source: self,
                    content: LogEntryContent(
                        function: function,
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
            addLogEntry(
                LogEntry(
                    category: .error,
                    source: self,
                    content: LogEntryContent(
                        function: function,
                        message: error.localizedDescription
                    )
                )
            )
        }
    }

    /// Dismisses the current logging interface.
    ///
    /// This helper method resets the active coordinator and, if a view controller is provided,
    /// dismisses it on the main actor to ensure proper UI thread management.
    ///
    /// - Parameter viewController: The `UIViewController` instance to dismiss. If `nil`, only the coordinator state is reset.
    private func dismiss() async {
        coordinator = nil
    }
}
