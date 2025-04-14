import UIKit
import VisualLogger

class ViewController: UIViewController {
    private var errorCount = 0

    // MARK: - Lazy vars

    private lazy var presentButton = UIButton(
        configuration: .bordered(),
        primaryAction: UIAction(title: "Present Logger", handler: { action in
            // Log only the action title instead of the entire action object.
            log.info(action.title, userInfo: [
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
            log.info(action.title, userInfo: [
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
            log.info(action.title, userInfo: [
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
            log.error("Error #\(errorCount) occurred", userInfo: [
                "code": 123,
                "domain": "example.com",
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
            log.info(
                action.title,
                userInfo: [
                    "newValue": newValue,
                    "oldValue": window.overrideUserInterfaceStyle,
                    "window": window,
                ]
            )
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
        log.info(userInfo: viewControllerDetails())
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView.frame = view.bounds
        log.verbose(userInfo: [
            "viewFrame": view.frame,
            "stackViewFrame": stackView.frame,
            "subviewsCount": view.allSuviews.count,
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.verbose(userInfo: [
            "event": "viewWillAppear",
            "animated": animated,
            "currentViewFrame": view.frame,
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VisualLogger.addAction(changeColorSchemeAction)
        log.verbose(userInfo: [
            "event": "viewDidAppear",
            "animated": animated,
            "currentViewFrame": view.frame,
        ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        log.verbose(userInfo: [
            "event": "viewWillDisappear",
            "animated": animated,
            "currentViewFrame": view.frame,
        ])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        VisualLogger.removeAction(changeColorSchemeAction)
        log.verbose(userInfo: [
            "event": "viewDidDisappear",
            "animated": animated,
            "currentViewFrame": view.frame,
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
            "stackViewArrangedSubviewsCount": stackView.arrangedSubviews.count,
        ]
    }
}

private extension UIView {
    var allSuviews: [UIView] {
        subviews.flatMap { [$0] + $0.allSuviews }
    }
}
