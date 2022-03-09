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

import AppLogger
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, LogConvertible {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else {
            log.error("No window scene")
            return
        }

        log.debug(userInfo: [
            "configuration": scene.session.configuration,
            "session": scene.session.debugDescription,
            "state": { () -> String in
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
            }()
        ])

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        AppLogger.current.window = window
        AppLogger.current.presentAppLogger()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        log.debug(userInfo: [
            "configuration": scene.session.configuration,
            "session": scene.session.debugDescription,
            "state": { () -> String in
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
            }()
        ])
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        log.debug(userInfo: [
            "configuration": scene.session.configuration,
            "session": scene.session.debugDescription,
            "state": { () -> String in
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
            }()
        ])
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        log.debug(userInfo: [
            "configuration": scene.session.configuration,
            "session": scene.session.debugDescription,
            "state": { () -> String in
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
            }()
        ])
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        log.debug(userInfo: [
            "configuration": scene.session.configuration,
            "session": scene.session.debugDescription,
            "state": { () -> String in
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
            }()
        ])
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        log.debug(userInfo: [
            "configuration": scene.session.configuration,
            "session": scene.session.debugDescription,
            "state": { () -> String in
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
            }()
        ])
    }
}
