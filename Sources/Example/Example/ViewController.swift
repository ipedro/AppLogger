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

import UIKit
import AppLogger

class ViewController: UIViewController {
    
    private lazy var presentButton = UIButton(
        configuration: .bordered(),
        primaryAction: UIAction(title: "Present Logger", handler: { action in
            Task { await AppLogger.current.present() }
            // Log only the action title instead of the entire action object.
            log.info(action.title, userInfo: [
                "discoverabilityTitle": action.discoverabilityTitle,
                "identifier": action.identifier.rawValue,
                "attributes": action.attributes.rawValue,
                "state": action.state.rawValue
            ])
        })
    )
    
    private lazy var presentLightButton = UIButton(
        configuration: .bordered(),
        primaryAction: UIAction(title: "Present Light Logger", handler: { action in
            Task { await AppLogger.current.present(configuration: .init(colorScheme: .light)) }
            // Log only the action title instead of the entire action object.
            log.info(action.title, userInfo: [
                "discoverabilityTitle": action.discoverabilityTitle,
                "identifier": action.identifier.rawValue,
                "attributes": action.attributes.rawValue,
                "state": action.state.rawValue
            ])
        })
    )
    
    private lazy var presentDarkButton = UIButton(
        configuration: .bordered(),
        primaryAction: UIAction(title: "Present Dark Logger", handler: { action in
            Task { await AppLogger.current.present(configuration: .init(colorScheme: .dark)) }
            log.info(action.title, userInfo: [
                "discoverabilityTitle": action.discoverabilityTitle,
                "identifier": action.identifier.rawValue,
                "attributes": action.attributes.rawValue,
                "state": action.state.rawValue
            ])
        })
    )
    
    private lazy var logErrorButton = UIButton(
        configuration: .bordered(),
        primaryAction: UIAction(title: "Log Error", handler: { action in
            // Log a small string message along with the action title.
            log.error("Error occurred", userInfo: [
                "code": 123,
                "domain": "example.com",
                "reason": "Something went wrong"
            ])
        })
    )
    
    private lazy var stackView = UIStackView(
        arrangedSubviews: [
            logErrorButton,
            presentButton,
            presentLightButton,
            presentDarkButton,
            UIView() // Extra view for layout purposes.
        ]
    )
    
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
        log.info(userInfo: viewControllerDetails())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView.frame = view.bounds
        log.verbose(userInfo: [
            "viewFrame": view.frame,
            "stackViewFrame": stackView.frame,
            "subviewsCount": view.allSuviews.count
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.verbose(userInfo: [
            "event": "viewWillAppear",
            "animated": animated,
            "currentViewFrame": view.frame
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log.verbose(userInfo: [
            "event": "viewDidAppear",
            "animated": animated,
            "currentViewFrame": view.frame
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        log.verbose(userInfo: [
            "event": "viewWillDisappear",
            "animated": animated,
            "currentViewFrame": view.frame
        ])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        log.verbose(userInfo: [
            "event": "viewDidDisappear",
            "animated": animated,
            "currentViewFrame": view.frame
        ])
    }
    
    /// Extracts key information about the view controller and its view.
    private func viewControllerDetails() -> [String: Any] {
        return [
            "className": String(describing: type(of: self)),
            "viewFrame": view.frame,
            "backgroundColor": view.backgroundColor?.description ?? "none",
            "subviewsCount": view.allSuviews.count,
            "stackViewAxis": stackView.axis == .horizontal ? "horizontal" : "vertical",
            "stackViewDistribution": stackView.distribution.rawValue,
            "stackViewArrangedSubviewsCount": stackView.arrangedSubviews.count
        ]
    }
}

private extension UIView {
    var allSuviews: [UIView] {
        subviews.flatMap { [$0] + $0.allSuviews }
    }
}
