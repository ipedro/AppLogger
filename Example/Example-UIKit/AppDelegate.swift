import UIKit
import VisualLogger
import XCGLogger

let log = XCGLogger.default

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    override init() {
        super.init()
        log.formatters = [VisualLoggerFormatter()]
        log.setup(
            level: .verbose,
            showLogIdentifier: false,
            showFunctionName: true,
            showThreadName: false,
            showLevel: true,
            showFileNames: true,
            showLineNumbers: true,
            showDate: true,
            writeToFile: .none,
            fileLevel: nil
        )
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        log.verbose(
            userInfo: [
                "state": application.applicationState.debugDescription,
                "badge number": String(application.applicationIconBadgeNumber),
            ]
        )
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        log.verbose(connectingSceneSession)
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        log.verbose(sceneSessions)
    }
}

extension UIApplication.State: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .active:
            "Active"
        case .inactive:
            "Inactive"
        case .background:
            "Background"
        default:
            "Default"
        }
    }
}
