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

    private lazy var button = UIButton (primaryAction: .init(title: "Present Logger", handler: { action in
        log.debug(action)
        AppLogger.current.presentAppLogger()
    }))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        log.info(self)
        self.view.backgroundColor = .systemBackground
        self.button.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        self.view.addSubview(self.button)
        self.button.sizeToFit()
        self.button.center = self.view.center
        self.view.layoutIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.debug(["animated": animated])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log.debug(["animated": animated])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        log.debug(["animated": animated])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        log.debug(["animated": animated])
    }

}

