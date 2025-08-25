//
//  NavigationManager.swift
//  SwiftUI AI Voice Assistant
//
//  Created by Alex Slater on 09/05/2024.
//

import SwiftUI
import Foundation
import UIKit

class NavigationManager: ObservableObject {
    @Published var screenList: [AnyView] = []
    @Published var selectedTab = MainTabs.home
    @Published var isCreated = false
    static let shared = NavigationManager()
    private init() {
        
    }
            
    // MARK: Pushing Functions
    
    public func presentView<V: View>(_ view: V, transition: UIModalTransitionStyle? = nil, completion: (() -> Void)? = nil) {
        let wrappedView = AnyView(view)

        let vc = DeeplinkContainer(NavigationDeepLinkContainerView(wrappedView))
        if let transition = transition {
            vc.modalTransitionStyle = transition
        }
        vc.modalPresentationStyle = .overCurrentContext
        UIApplication.shared.topVC?.present(vc, animated: true, completion: completion)
        
    }

    
    // MARK: Popping functions

    public func dismissView() {
        UIApplication.shared.topVC?.dismiss(animated: true)
    }
}

extension UIApplication {
    
    static var fullWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var fullHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    public var topVC: UIViewController? {
        return topViewController(rootVC)
    }
    
    private var rootVC: UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        return windowScene.windows.first?.rootViewController
    }
    
    private func topViewController(_ base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

class DeeplinkContainer : UIViewController {
    
    var containerView: UIView?
    
    init<V: View>(_ swiftUIView: V) {
        super.init(nibName: nil, bundle: nil)
        containerView = getUIView(swiftUIView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getUIView<V: View>(_ swiftUIView: V) -> UIView {
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(hostingController)
        return hostingController.view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let containerView = containerView {
            view.addSubview(containerView)
            setupConstraints(containerView)
        }
        
    }
    
    fileprivate func setupConstraints(_ containerView : UIView){
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
    }
    
}

struct NavigationDeepLinkContainerView<Content: View>: View {
    
    private let content: Content
    
    init(_ view: Content) {
        content = view
    }
    
    var body: some View {
        NavigationStack {
            content
        }
        .navigationBarBackButtonHidden()
    }
    
}

enum CurrentEnvironment: String {
    case debug
    case release
}

struct Constants {
    static var randomUUID = UUID().uuidString
    static var currentEnvironment: CurrentEnvironment {
        
      #if DEBUG
        return .debug
      #else
        return .release
      #endif
        
    }
    
    static var daysElapsed: Int {
        let uid = PersistanceManager.shared.retrieveFile(.daysElapsed) as? Int
        
        guard let uid = uid else {
            return 0
        }
        return uid
    }
    
    static var uid: String {
        let uid = PersistanceManager.shared.retrieveFile(.uid) as? String
        
        guard let uid = uid else {
            return ""
        }
        return uid
    }
    
    static var isOnboarded: Bool {
        if PersistanceManager.shared.fileExists(.onboarded) {
            return true
        } else {
            return false
        }
    }
    
    static var groupJoined: Bool {
        if PersistanceManager.shared.fileExists(.groupJoined) {
            return true
        } else {
            return false
        }
    }

    static var webAuthEmail: String? {
        if PersistanceManager.shared.fileExists(.webAuthEmail) {
            return PersistanceManager.shared.retrieveFile(.webAuthEmail) as? String
        } else {
            return nil
        }
    }

    static var demo: Bool {
        if PersistanceManager.shared.fileExists(.demo) {
            return true
        } else {
            return false
        }
    }
    
    static var subscriber: Bool {
        if PersistanceManager.shared.fileExists(.subscriber) {
            return true
        } else {
            return false
        }
    }
    
    static var lifetime: Bool {
        if PersistanceManager.shared.fileExists(.lifetime) {
            return true
        } else {
            return false
        }
    }
}

class PersistanceManager {
    
    enum FileType: String, CaseIterable {
        
        // MARK: Function Attributes
        case user, notifAuth, uid, firstLogin, askReview, onboarded, appLocked, dailyNotifications, daysElapsed, demo, moodCheckIn, communitySheet, groupJoined, signedIn, confirmedProfile, sentDiscountNoti, emailSub, webAuthEmail, subscriber, lifetime
        
        // MARK: Placeholder/Popup
        case all
        
    }
    
    static let shared = PersistanceManager()
    private init() {}
    
    public func saveFile(_ file: FileType, value: Any) {
        
        if let arrayValue = value as? [[String: Any?]] {
            var finalValue: [[String: Any]] = []
            for item in arrayValue {
                var temp: [String: Any] = [:]
                for (itemKey, itemValue) in item {
                    if let stringValue = itemValue as? String {
                        temp[itemKey] = stringValue
                    }
                    if let numValue = itemValue as? NSNumber {
                        temp[itemKey] = numValue
                    }
                }
                finalValue.append(temp)
            }
            UserDefaults.standard.set(finalValue, forKey: file.rawValue)
            return
        }
        
        if let dictValue = value as? [String: Any?] {
            var finalValue: [String: Any] = [:]
            for (key, value) in dictValue {
                if dictValue[key] != nil {
                    finalValue[key] = value
                }
            }
            UserDefaults.standard.set(finalValue, forKey: file.rawValue)
            return
        }
        
        UserDefaults.standard.set(value, forKey: file.rawValue)
        
    }
    
    
    public func fileExists(_ file: FileType) -> Bool {
        let value = UserDefaults.standard.object(forKey: file.rawValue)
        if value == nil {
            return false
        }
        return true
    }
    
    public func retrieveFile(_ file: FileType) -> Any? {
        return UserDefaults.standard.value(forKey: file.rawValue)
    }
    
    public func deleteFile(_ file: FileType) {
        if file == .all {
            for file in FileType.allCases {
                UserDefaults.standard.removeObject(forKey: file.rawValue)
            }
            return
        }
        UserDefaults.standard.removeObject(forKey: file.rawValue)
    }
    
    public func saveCodableFile<T: Codable>(_ file: FileType, value: T) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let data = try? encoder.encode(value) {
            UserDefaults.standard.set(data, forKey: file.rawValue)
        }
    }
    
    public func retrieveCodableFile<T: Codable>(_ file: FileType) -> T? {
        
        guard let data = UserDefaults.standard.value(forKey: file.rawValue) as? Data else {return nil}
        return try? JSONDecoder().decode(T.self, from: data)
        
    }
}
