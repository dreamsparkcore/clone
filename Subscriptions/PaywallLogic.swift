import SwiftUI
import SuperwallKit

class ViewController: UIViewController, SuperwallDelegate {
    @AppStorage("age") private var userAge: Int = 0
    func pressedButton() {
        if userAge < 18 {
            Superwall.shared.register(placement: "under18")
        } else if userAge <= 22 {
            Superwall.shared.register(placement: "age18to22")
        } else if userAge <= 28 {
            Superwall.shared.register(placement: "age23to28")
        } else if userAge <= 40 {
            Superwall.shared.register(placement: "age29to40")
        } else if userAge > 40 {
            Superwall.shared.register(placement: "over40")
        }
    }

    func fiftyOff() {
        Superwall.shared.register(placement: "fiftyOff")
    }
    
    func free_trial() {
        Superwall.shared.register(placement: "free_trial")
    }

    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        
        guard case let .transactionComplete(transaction, product, transactionType, paywallInfo) = eventInfo.event else {
            print("Default event: \(eventInfo.event.description)")
            
            return
        }

        print("TRANSACTION CONFIRMED")
        
        guard let sk2Transaction = transaction?.sk2Transaction else { return }
        
        let productDetails: [String: Double] = [
            "monthly": 14.99,
            "yearly": 29.99,
            "monthly_3d": 12.99,
            "yearly_3d": 49.99,
            "yearly_3d_trial": 19.99,
            "monthly_999": 9.99,
            "yearly_49": 19.99,
            "weekly": 4.99,
            "yearly_quittr": 39.99,
            "yearly_99": 49.99,
        ]

        AnalyticsManager.shared.trackEvent(eventName: "paywall_purchase_successful", properties: ["paywall_variant": paywallInfo.name,
                                                                                                  "transaction_type": transactionType.rawValue,
                                                                                                  "product_id": product.productIdentifier,
                                                                                                  "raw_price": product.price,
                                                                                                  "currency": product.currencyCode ?? "",
                                                                                                  "price": product.localizedPrice,
                                                                                                  "duration": product.period
                                                                                                 ])

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        if let revenue = productDetails[sk2Transaction.productID] {
            print("\(revenue), currency: 'USD'")
//            event?.setRevenue(revenue, currency: "USD")
//            Adjust.trackEvent(event)
        } else {
            print("Unhandled productID: \(sk2Transaction.productID)")
        }
        
        handleSuccess()
    }
    
    func handleSuccess() {
        PersistanceManager.shared.saveFile(.firstLogin, value: true)
        PersistanceManager.shared.saveFile(.communitySheet, value: true)
        let view = MainTabView()
        NavigationManager.shared.presentView(view)
    }
}
