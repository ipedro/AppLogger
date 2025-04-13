import Data
import SwiftUI
import UI

/// Coordinator manages the presentation of the logging interface.
/// It coordinates the UI presentation by integrating SwiftUI views within a UIKit context and handles dismissal actions.
@MainActor
final class Coordinator: NSObject {
    /// Data observer used for monitoring log data updates.
    private let dataObserver: DataObserver

    /// Custom configuration for the logging interface presentation.
    private let configuration: VisualLoggerConfiguration

    /// Closure for handling dismissal of the presented view controller.
    private let dismiss: () -> Void

    /// Weak reference to the currently presented view controller.
    private weak var viewController: UIViewController?

    /// Initializes a new instance of Coordinator.
    ///
    /// - Parameters:
    ///   - dataObserver: The data observer responsible for monitoring log data updates.
    ///   - configuration: Custom configuration for the logging interface.
    ///   - dismiss: A closure that handles view controller dismissal.
    init(
        dataObserver: DataObserver,
        configuration: VisualLoggerConfiguration,
        dismiss: @escaping @Sendable () async -> Void
    ) {
        self.dataObserver = dataObserver
        self.configuration = configuration
        self.dismiss = {
            Task {
                await dismiss()
            }
        }
    }

//    deinit {
//        debugPrint(#function, "VisualLoggerCoordinator released")
//    }

    /// Retrieves the key window used for presenting the logging interface.
    private var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .filter(\.isKeyWindow)
            .first
    }

    private lazy var viewModel = VisualLoggerViewModel(
        dataObserver: dataObserver,
        dismissAction: { [unowned self] in
            dismissAction()
        }
    )

    /// Presents the logging interface modally.
    ///
    /// This method creates and presents the appropriate view controller based on the current iOS version.
    /// It configures sheet presentation parameters when available.
    ///
    /// - Parameters:
    ///   - animated: A Boolean value indicating whether the presentation should be animated (default is true).
    ///   - completion: An optional closure called after the presentation is complete.
    func present(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard
            viewController == nil,
            let presentingController = keyWindow?.rootViewController?.topPresentedViewController
        else {
            return
        }

        let viewController = makeViewController()
        self.viewController = viewController

        if let sheetPresentation = viewController.sheetPresentationController {
            sheetPresentation.detents = [.large(), .medium()]
            sheetPresentation.selectedDetentIdentifier = .medium
            sheetPresentation.prefersGrabberVisible = true
            sheetPresentation.prefersScrollingExpandsWhenScrolledToEdge = false
            sheetPresentation.largestUndimmedDetentIdentifier = .large
            sheetPresentation.delegate = self
        }

        presentingController.present(
            viewController,
            animated: animated,
            completion: completion
        )
    }

    /// Handles the dismissal of the presented view controller.
    ///
    /// This method is invoked by the view model to trigger the dismissal action.
    private func dismissAction() {
        viewController?.dismiss(animated: true)
        dismiss()
    }

    /// Creates and returns the view controller for presenting the logging interface.
    ///
    /// This method selects the appropriate SwiftUI view presentation based on the iOS version.
    ///
    /// - Returns: A UIViewController encapsulating the logging interface.
    func makeViewController() -> UIViewController {
        if #available(iOS 16.0, *) {
            UIHostingController(rootView: makeNavigationStack())
        } else {
            // Fallback on earlier versions
            UIHostingController(rootView: makeNavigationView())
        }
    }

    /// Constructs and returns a SwiftUI view for navigation, supporting older iOS versions.
    ///
    /// - Returns: A SwiftUI view representing the navigation view.
    func makeNavigationView() -> some View {
        injectDependencies(VisualLoggerView.navigationView())
    }

    /// Constructs and returns a SwiftUI view using a navigation stack (iOS 16.0+).
    ///
    /// - Returns: A SwiftUI view representing the navigation stack.
    @available(iOS 16.0, *)
    func makeNavigationStack() -> some View {
        injectDependencies(VisualLoggerView.navigationStack())
    }

    /// Injects the necessary dependencies into the provided SwiftUI view.
    ///
    /// - Parameter view: A SwiftUI view that requires dependency injection.
    /// - Returns: The modified SwiftUI view with the configuration and view model injected.
    func injectDependencies(_ view: some View) -> some View {
        view
            .configuration(configuration)
            .environmentObject(viewModel)
    }
}

/// Extension to conform to UISheetPresentationControllerDelegate for handling presentation dismissal events.
extension Coordinator: UISheetPresentationControllerDelegate {
    /// Notifies the delegate when the presentation controller has dismissed the view.
    ///
    /// - Parameter _: The presentation controller that was dismissed.
    func presentationControllerDidDismiss(_: UIPresentationController) {
        // Presentation has ended; clear the view controller reference.
        dismiss()
    }
}

/// Extension for obtaining the top-most presented view controller from a UIViewController.
private extension UIViewController {
    /// Recursively finds and returns the top presented view controller.
    var topPresentedViewController: UIViewController {
        presentedViewController?.topPresentedViewController ?? self
    }
}
