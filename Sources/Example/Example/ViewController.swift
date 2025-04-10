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
    
    private lazy var presentLightButton: UIButton = {
        return UIButton(primaryAction: .init(title: "Present Light Logger", handler: { action in
            Task { await AppLogger.current.present(configuration: .init(colorScheme: .light)) }
            // Log only the action title instead of the entire action object.
            log.notice(userInfo: ["actionTitle": action.title])
        }))
    }()
    
    private lazy var presentDarkButton: UIButton = {
        return UIButton(primaryAction: .init(title: "Present Dark Logger", handler: { action in
            Task { await AppLogger.current.present(configuration: .init(colorScheme: .dark)) }
            log.notice(userInfo: ["actionTitle": action.title])
        }))
    }()
    
    private lazy var logErrorButton: UIButton = {
        return UIButton(primaryAction: .init(title: "Log Error", handler: { action in
            // Log a small string message along with the action title.
            log.error("Error occurred", userInfo: ["actionTitle": action.title])
        }))
    }()
    
    private lazy var stackView: UIStackView = {
        return UIStackView(
            arrangedSubviews: [
                logErrorButton,
                presentLightButton,
                presentDarkButton,
                UIView() // Extra view for layout purposes.
            ]
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
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
