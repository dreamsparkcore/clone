import SwiftUI
import SuperwallKit

struct SubRootView: View {

    var body: some View {
        Group {
            if Superwall.shared.subscriptionStatus.isActive {
                MainTabView()
            } else if Constants.isOnboarded {
                PaywallView(onComplete: {})
            } else {
                Root()
            }
        }
    }
}
