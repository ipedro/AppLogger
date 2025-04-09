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
//  SOFTWARE.import UIKit

import UIKit
import AppLogger

class ViewController: UIViewController {

    private lazy var presentLightButton = UIButton(primaryAction: .init(title: "Present Light Logger", handler: { action in
        Task { await AppLogger.current.present() }
        log.notice(action.title)
    }))

    private lazy var presentDarkButton = UIButton(primaryAction: .init(title: "Present Dark Logger", handler: { action in
        Task { await AppLogger.current.present() }
        log.notice(action.title)
    }))

    private lazy var logErrorButton = UIButton(primaryAction: .init(title: "Log Error", handler: { action in
        log.error("I'm an error log")
    }))

    private lazy var stackView = UIStackView(
        arrangedSubviews: [
            logErrorButton,
            presentLightButton,
            presentDarkButton,
            UIView()
        ]
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        log.info(self)
        view.backgroundColor = .systemBackground
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        view.layoutIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView.frame = view.bounds
        log.verbose(
            self,
            userInfo: [
                "frame": view.frame,
                "subviews": view.allSuviews.count
            ]
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.verbose(self, userInfo: ["animated": animated])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log.verbose(self, userInfo: ["animated": animated])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        log.verbose(self, userInfo: ["animated": animated])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        log.verbose(self, userInfo: ["animated": animated])
    }

}

private extension UIView {
    var allSuviews: [UIView] {
        subviews.flatMap { [$0] + $0.allSuviews }
    }
}
