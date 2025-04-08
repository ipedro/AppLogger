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

public final class AppLogger: NSObject, AppLoggerPresenting, AppLogging {
    public var window: UIWindow?

    static let sharedInstance = AppLogger()

    private override init() {}

    public var configuration: AppLoggerConfiguration {
        get { viewModel.configuration }
        set { viewModel.configuration = newValue }
    }

    var viewModel = ViewModel()

    private(set) lazy var coordinator = AppLoggerCoordinator(viewModel: viewModel)

    public func addLogEntry(_ entry: LogEntry) {
        viewModel.addLogEntry(entry)
    }

    public func export() -> AppLoggerCSV {
        viewModel.csv()
    }

    func navigationView(onDismiss: @escaping () -> Void) -> some View {
        coordinator.navigationView(onDismiss: onDismiss)
    }

    public func present(animated: Bool, configuration: AppLoggerConfiguration?, completion: (() -> Void)?) {
        guard let window = window else {
            assertionFailure("Please inject a valid window in '\(type(of: self)).current' (usually done at AppDelegate or SceneDelegate). For SwiftUI use the `.appLogger()` view modifier.")
            return
        }

        if let configuration = configuration {
            self.configuration = configuration
        }
        
        let startViewController = coordinator.start()

        if let sheetPresentation = startViewController.sheetPresentationController {
            sheetPresentation.detents = [.large(), .medium()]
            sheetPresentation.selectedDetentIdentifier = .medium
            sheetPresentation.prefersGrabberVisible = true
            sheetPresentation.prefersScrollingExpandsWhenScrolledToEdge = false
            sheetPresentation.delegate = self
            viewModel.setCompactPresentation(true, in: window)
        }

        window.rootViewController?.topPresentedViewController.present(
            startViewController,
            animated: animated,
            completion: completion
        )
    }
}

// MARK: - UISheetPresentationControllerDelegate

extension AppLogger: UISheetPresentationControllerDelegate {
    public func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        guard let window = window else { return }
        viewModel.setCompactPresentation(
            sheetPresentationController.selectedDetentIdentifier == .medium,
            in: window
        )
    }

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        coordinator.stop()
    }
}
