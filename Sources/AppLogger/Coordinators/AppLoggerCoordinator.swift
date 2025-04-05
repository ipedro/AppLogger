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

import Foundation
import SwiftUI
import UIKit

final class AppLoggerCoordinator: NSObject {
    let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    private var startViewController: UIViewController?

    func start() -> UIViewController {
        let viewController = startViewController ?? makeStartViewController()
        startViewController = viewController
        return viewController
    }

    @discardableResult
    func stop() -> Bool {
        if startViewController == nil { return false }
        startViewController?.dismiss(animated: true, completion: .none)
        startViewController = .none
        return true
    }

    func navigationView(onDismiss: @escaping () -> Void) -> some View {
        AppLoggerView(dismiss: onDismiss)
            .environmentObject(viewModel)
    }
}

// MARK: - Private Helpers

private extension AppLoggerCoordinator {
    func makeStartViewController() -> UIViewController {
        let hostingController = UIHostingController(
            rootView: navigationView { [weak self] in
                self?.stop()
            }
        )
        return hostingController
    }
}
