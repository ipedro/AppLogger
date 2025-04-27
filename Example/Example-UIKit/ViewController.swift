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

import UIKit
import VisualLogger

class ViewController: UIViewController {
    private var errorCount = 0

    // MARK: - Lazy vars

    private lazy var presentButton = UIButton(
        configuration: .bordered(),
        primaryAction: UIAction(title: "Present Logger", handler: { action in
            // Log only the action title instead of the entire action object.
            print(action.title, [
                "discoverabilityTitle": action.discoverabilityTitle ?? "–",
                "identifier": action.identifier.rawValue,
                "attributes": action.attributes.rawValue,
                "state": action.state.rawValue,
            ])

            VisualLogger.present()
        })
    )

    private lazy var presentLightButton = UIButton(
        configuration: .bordered(),
        primaryAction: UIAction(title: "Present Light Logger", handler: { action in
            // Log only the action title instead of the entire action object.
            print(action.title, [
                "discoverabilityTitle": action.discoverabilityTitle ?? "–",
                "identifier": action.identifier.rawValue,
                "attributes": action.attributes.rawValue,
                "state": action.state.rawValue,
            ])

            VisualLogger.present(configuration: .init(colorScheme: .light))
        })
    )

    private lazy var presentDarkButton = UIButton(
        configuration: .bordered(),
        primaryAction: UIAction(title: "Present Dark Logger", handler: { action in
            print(action.title, [
                "discoverabilityTitle": action.discoverabilityTitle ?? "–",
                "identifier": action.identifier.rawValue,
                "attributes": action.attributes.rawValue,
                "state": action.state.rawValue,
            ])

            VisualLogger.present(configuration: .init(colorScheme: .dark))
        })
    )

    private lazy var logErrorButton = UIButton(
        configuration: .bordered(),
        primaryAction: UIAction(title: "Log Error", handler: { [unowned self] _ in
            // Log a small string message along with the action title.
            print("Error #\(errorCount) occurred", [
                "code": 123,
                "domain": "https://example.com",
                "reason": "Something went wrong",
            ])
            errorCount += 1
        })
    )

    private lazy var stackView = UIStackView(
        arrangedSubviews: [
            logErrorButton,
            presentButton,
            presentLightButton,
            presentDarkButton,
            UIView(), // Extra view for layout purposes.
        ]
    )

    private lazy var changeColorSchemeAction = VisualLoggerAction(
        title: "Change Color Scheme",
        systemImage: "circle.lefthalf.striped.horizontal",
        handler: { [unowned self] action in
            guard let window = view?.window else {
                return
            }
            let newValue: UIUserInterfaceStyle = if window.overrideUserInterfaceStyle == .dark {
                .light
            } else {
                .dark
            }
            print([
                "action": "Change Color Scheme",
                "newValue": newValue,
                "oldValue": window.overrideUserInterfaceStyle,
                "window": window,
            ])
            window.overrideUserInterfaceStyle = newValue
        }
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = .init(
            top: 20,
            leading: 20,
            bottom: 20,
            trailing: 20
        )
        view.addSubview(stackView)
        view.layoutIfNeeded()

        // Log key details from the view controller without logging entire objects.
        print(viewControllerDetails)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView.frame = view.bounds
        print([
            "viewFrame": view.frame,
            "stackViewFrame": stackView.frame,
            "subviewsCount": view.allSuviews.count,
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print([
            "event": "viewWillAppear",
            "animated": animated,
            "currentViewFrame": view.frame,
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VisualLogger.addAction(changeColorSchemeAction)
        print([
            "event": "viewDidAppear",
            "animated": animated,
            "currentViewFrame": view.frame,
        ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print([
            "event": "viewWillDisappear",
            "animated": animated,
            "currentViewFrame": view.frame,
        ])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        VisualLogger.removeAction(changeColorSchemeAction)
        print([
            "event": "viewDidDisappear",
            "animated": animated,
            "currentViewFrame": view.frame,
        ])
    }

    /// Extracts key information about the view controller and its view.
    private func viewControllerDetails() -> [String: Any] {
        [
            "className": String(describing: type(of: self)),
            "viewFrame": view.frame,
            "backgroundColor": view.backgroundColor?.description ?? "none",
            "subviewsCount": view.allSuviews.count,
            "stackViewAxis": stackView.axis == .horizontal ? "horizontal" : "vertical",
            "stackViewDistribution": stackView.distribution.rawValue,
            "stackViewArrangedSubviewsCount": stackView.arrangedSubviews.count,
        ]
    }
}

private extension UIView {
    var allSuviews: [UIView] {
        subviews.flatMap { [$0] + $0.allSuviews }
    }
}
