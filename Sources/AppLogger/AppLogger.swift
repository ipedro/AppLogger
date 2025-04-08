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

import class Data.DataStore
import class Data.DataObserver
import class ObjectiveC.NSObject
import class SwiftUI.UIHostingController
import class UIKit.UIApplication
import class UIKit.UIPresentationController
import class UIKit.UISheetPresentationController
import class UIKit.UIViewController
import class UIKit.UIWindow
import class UIKit.UIWindowScene
import protocol UIKit.UISheetPresentationControllerDelegate
import struct Models.AppLoggerConfiguration
import struct Models.LogEntry
import struct UI.AppLoggerView
import class UI.AppLoggerViewModel
import protocol SwiftUI.View

public actor AppLogger {
    private let dataStore = DataStore()
    
    private var coordinator: Coordinator?

    public static let current = AppLogger()
    
    public var configuration = AppLoggerConfiguration()
    
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
        self.viewController = viewController
        
        if let sheetPresentation = viewController.sheetPresentationController {
            sheetPresentation.detents = [.large(), .medium()]
            sheetPresentation.selectedDetentIdentifier = .medium
            sheetPresentation.prefersGrabberVisible = true
            sheetPresentation.prefersScrollingExpandsWhenScrolledToEdge = false
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
        UIHostingController(rootView: rootView())
    }
    
    func rootView() -> some View {
        AppLoggerView()
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
