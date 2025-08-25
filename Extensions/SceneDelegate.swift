import UIKit

@MainActor
final class SceneDelegate: NSObject, UIWindowSceneDelegate {

    // Called on cold launch when the app is opened via a quick action
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        if let shortcutItem = connectionOptions.shortcutItem {
            // Cache for SwiftUI to consume once UI is ready
            AppDelegate.pendingQuickAction = QuickAction(rawValue: shortcutItem.type)
            // Also post for warm-ish cases
            NotificationCenter.default.post(
                name: .didTriggerQuickAction,
                object: nil,
                userInfo: ["action": AppDelegate.pendingQuickAction as Any]
            )
        }
    }

    // Called when app is already running (warm) and the user picks a quick action
    func windowScene(_ windowScene: UIWindowScene,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        let handled = QuickAction(rawValue: shortcutItem.type) != nil
        if let action = QuickAction(rawValue: shortcutItem.type) {
            AppDelegate.pendingQuickAction = action
            NotificationCenter.default.post(
                name: .didTriggerQuickAction,
                object: nil,
                userInfo: ["action": action]
            )
        }
        completionHandler(handled)
    }
}
