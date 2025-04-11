import AppLogger
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // Helper function to consolidate scene details for logging.
    private func sceneDetails(for scene: UIScene) -> [String: Any] {
        // Break down session and configuration details into smaller parts.
        var details: [String: Any] = [
            "persistentIdentifier": scene.session.persistentIdentifier,
            "name": scene.session.configuration.name!,
            "sessionRole": scene.session.configuration.role.rawValue,
            "activationState": {
                switch scene.activationState {
                case .background:
                    return "Background"
                case .foregroundActive:
                    return "Foreground Active"
                case .foregroundInactive:
                    return "Foreground Inactive"
                case .unattached:
                    return "Unattached"
                default:
                    return "Unknown"
                }
            }(),
        ]

        if let windowScene = scene as? UIWindowScene {
            let trait = windowScene.traitCollection
            details["interfaceOrientation"] = windowScene.interfaceOrientation.rawValue
            details["screenBounds"] = windowScene.screen.bounds
            details["userInterfaceStyle"] = trait.userInterfaceStyle == .dark ? "dark" : "light"
            details["horizontalSizeClass"] = trait.horizontalSizeClass == .compact ? "compact" : "regular"
            details["verticalSizeClass"] = trait.verticalSizeClass == .compact ? "compact" : "regular"
            details["displayScale"] = trait.displayScale
            details["preferredContentSizeCategory"] = trait.preferredContentSizeCategory.rawValue
            details["windowsCount"] = windowScene.windows.count
            details["isFullScreen"] = windowScene.isFullScreen
        }

        return details
    }

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        // Ensure the scene is a UIWindowScene
        guard let windowScene = (scene as? UIWindowScene) else {
            log.error("No window scene")
            return
        }

        // Log enriched scene details with smaller, extracted properties.
        log.info(userInfo: sceneDetails(for: scene))

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        log.info(userInfo: sceneDetails(for: scene))
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        log.info(userInfo: sceneDetails(for: scene))
    }

    func sceneWillResignActive(_ scene: UIScene) {
        log.info(userInfo: sceneDetails(for: scene))
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        log.info(userInfo: sceneDetails(for: scene))
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        log.info(userInfo: sceneDetails(for: scene))
    }
}
