import Data
import UIKit

public actor AppLogger {
    private let dataStore = DataStore()
    
    private var coordinator: Coordinator?

    public static let current = AppLogger()
    
    /// Adds a log entry to the DataStore.
    ///
    /// - Parameter logEntry: The log entry to add.
    nonisolated public func addLogEntry(_ log: LogEntry) {
        Task {
            await dataStore.addLogEntry(log)
        }
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
