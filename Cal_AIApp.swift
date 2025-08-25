//
//  Cal_AIApp.swift
//  Cal AI
//
//  Created by Alex Slater on 19/8/25.
//

import SwiftUI
import UIKit
import SuperwallKit

// MARK: - Quick Action Types
enum QuickAction: String {
    case sendFeedback = "com.calai.sendFeedback"
    case annualPlan   = "com.calai.annualPlan"
}

// MARK: - Notification for routing quick actions to SwiftUI (warm app)
extension Notification.Name {
    static let didTriggerQuickAction = Notification.Name("didTriggerQuickAction")
}

// MARK: - AppDelegate (handles Superwall + Quick Actions)
final class AppDelegate: NSObject, UIApplicationDelegate {
    static var pendingQuickAction: QuickAction?   // <— keep this

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Superwall.configure(apiKey: "superwall-key-here")
        updateQuickActions(for: application)
        return true
    }

    // Handle quick action when app is already running (warm app)
    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let handled = handle(shortcutItem: shortcutItem)
        completionHandler(handled)
    }

    // MARK: - Helpers

    @discardableResult
    private func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let action = QuickAction(rawValue: shortcutItem.type) else { return false }

        // Cache for cold-launch consumption.
        AppDelegate.pendingQuickAction = action

        // Also post for warm app so SwiftUI can react immediately.
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .didTriggerQuickAction,
                object: nil,
                userInfo: ["action": action]
            )
        }
        return true
    }

    private func updateQuickActions(for application: UIApplication) {
        var items: [UIApplicationShortcutItem] = []

        let feedbackItem = UIApplicationShortcutItem(
            type: QuickAction.sendFeedback.rawValue,
            localizedTitle: "Deleting? Tell us why.",
            localizedSubtitle: "Send feedback before you delete",
            icon: UIApplicationShortcutIcon(systemImageName: "square.and.pencil")
        )
        items.append(feedbackItem)

        let annualPlanItem = UIApplicationShortcutItem(
            type: QuickAction.annualPlan.rawValue,
            localizedTitle: "🚨 TRY FOR FREE",
            localizedSubtitle: "Get unlimited access to the Cal AI app",
            icon: UIApplicationShortcutIcon(systemImageName: "gift")
        )
        items.append(annualPlanItem)

        application.shortcutItems = items
    }
}

// MARK: - SwiftUI App
@main
struct Cal_AIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    private let websiteURL = URL(string: "https://forms.gle/2yh1WAr8aNqxkL3P8")!

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .onReceive(NotificationCenter.default.publisher(for: .didTriggerQuickAction)) { note in
                    if let action = (note.userInfo?["action"] as? QuickAction) ?? AppDelegate.pendingQuickAction {
                        AppDelegate.pendingQuickAction = nil
                        handleQuickAction(action)
                    }
                }
                .onAppear { consumePendingQuickActionIfAny() }
        }
        .onChange(of: scenePhase) { if $0 == .active { consumePendingQuickActionIfAny() } }
    }

    @MainActor private func consumePendingQuickActionIfAny() {
        if let action = AppDelegate.pendingQuickAction {
            AppDelegate.pendingQuickAction = nil
            handleQuickAction(action)
        }
    }

    @MainActor
    private func handleQuickAction(_ action: QuickAction) {
        switch action {
        case .sendFeedback:
            openURL(websiteURL)
        case .annualPlan:
            // If you actually want to trigger Superwall logic, prefer register(event:)
            // based on your rules, or present a placement/paywall explicitly:
            // Task { try? await Superwall.shared.register(event: "free_trial") }
            print("Quick Action: Annual Plan tapped")
            Superwall.shared.register(placement: "free_trial")
        }
    }
}
