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
                    "Background"
                case .foregroundActive:
                    "Foreground Active"
                case .foregroundInactive:
                    "Foreground Inactive"
                case .unattached:
                    "Unattached"
                default:
                    "Unknown"
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
