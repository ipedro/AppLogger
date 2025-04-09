//  Copyright (c) 2025 Pedro Almeida
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

import class Data.AppLoggerViewModel
import class Data.DataObserver
import class ObjectiveC.NSObject
import class SwiftUI.UIHostingController
import class UIKit.UIApplication
import class UIKit.UIPresentationController
import class UIKit.UISheetPresentationController
import class UIKit.UIViewController
import class UIKit.UIWindow
import class UIKit.UIWindowScene
import protocol SwiftUI.View
import protocol UIKit.UISheetPresentationControllerDelegate
import struct Models.AppLoggerConfiguration
import struct UI.LogEntriesNavigationView

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
        LogEntriesNavigationView()
            .configuration(configuration)
            .environmentObject(viewModel)
            .environmentObject(dataObserver)
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
