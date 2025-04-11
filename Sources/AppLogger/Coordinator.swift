import Data
import SwiftUI
import UI

@MainActor
final class Coordinator: NSObject {
    private let dataObserver: DataObserver
    
    private let configuration: AppLoggerConfiguration
    
    private let dismiss: (UIViewController?) -> Void
    
    private weak var viewController: UIViewController?
    
    init(
        dataObserver: DataObserver,
        configuration: AppLoggerConfiguration,
        dismiss: @escaping (_ viewController: UIViewController?) -> Void
    ) {
        self.dataObserver = dataObserver
        self.configuration = configuration
        self.dismiss = dismiss
    }
    
    private var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .filter(\.isKeyWindow)
            .first
    }
    
    private lazy var viewModel = AppLoggerViewModel(
        dataObserver: dataObserver,
        dismissAction: dismissAction
    )
    
    func present(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard
            viewController == nil,
            let presentingController = keyWindow?.rootViewController?.topPresentedViewController
        else {
            return
        }
        
        let viewController = makeViewController()
        print(type(of: viewController))
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
    
    private func dismissAction() {
        dismiss(viewController)
    }
    
    func makeViewController() -> UIViewController {
        if #available(iOS 16.0, *) {
            UIHostingController(rootView: makeNavigationStack())
        } else {
            // Fallback on earlier versions
            UIHostingController(rootView: makeNavigationView())
        }
    }
    
    func makeNavigationView() -> some View {
        injectDependencies(AppLoggerView.navigationView())
    }
    
    @available(iOS 16.0, *)
    func makeNavigationStack() -> some View {
        injectDependencies(AppLoggerView.navigationStack())
    }
    
    func injectDependencies(_ view: some View) -> some View {
        view
            .configuration(configuration)
            .environmentObject(viewModel)
    }
}

extension Coordinator: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // presentation has already ended, no need to send VC reference.
        dismiss(nil)
    }
}

private extension UIViewController {
    var topPresentedViewController: UIViewController {
        presentedViewController?.topPresentedViewController ?? self
    }
}
