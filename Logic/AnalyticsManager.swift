import SwiftUI
import Mixpanel
import SuperwallKit

class AnalyticsManager {

    typealias Properties = [String: Any]
    typealias Event = String

    static let shared = AnalyticsManager()

    func identify(name: String?, userId: String, email: String) {
        let attributes: [String: Any] = [
            "name": name ?? "",
            "email": email
        ]

        // Mixpanel
        Mixpanel.mainInstance().identify(distinctId: userId)
        Mixpanel.mainInstance().people.set(properties: attributes as? [String: MixpanelType] ?? [:])

        // Superwall
        Superwall.shared.identify(userId: userId)
        Superwall.shared.setUserAttributes(attributes)
    }

    func updateUserAttributes(attributes: [String: Any]) {
        Mixpanel.mainInstance().people.set(properties: attributes as? [String: MixpanelType] ?? [:])
        Mixpanel.mainInstance().registerSuperProperties(attributes as? [String: MixpanelType] ?? [:])
        Superwall.shared.setUserAttributes(attributes)
    }

    func trackEvent(eventName: Event, properties: Properties? = nil) {
        trackMixpanel(eventName, properties: properties)
    }

    private func trackMixpanel(_ event: String, properties: Properties? = nil) {
        Mixpanel.mainInstance().track(event: event, properties: properties as? [String: MixpanelType])
    }
}
