import SwiftUI
import AppTrackingTransparency

struct ReferralCodeView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("referallCode") private var text: String = ""
    let onComplete: () -> Void
    var body: some View {
                VStack(alignment: .leading) {
                    Text(LocalizedStringKey("Do you have a referral code?"))
                        .fontWeight(.bold)
                        .font(.largeTitle)
                        .padding(.bottom, 6)
                    Text(LocalizedStringKey("You can skip this step."))
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 15)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    ZStack(alignment: .topLeading){
                        TextField(LocalizedStringKey("Referral Code"), text: $text)
                            .scrollContentBackground(.hidden)
                            .tint(.primary.opacity(0.8))
                            .padding(.init(top: 10, leading: 16, bottom: 10, trailing: 16))
                            .frame(height: 55)
                            .background {
                                RoundedRectangle(cornerRadius: 35)
                                    .foregroundColor(Color(hex: "#0D0831").opacity(0.65))
                            }
                            .overlay(
                                                                      RoundedRectangle(cornerRadius: 35)
                                                                          .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                                  )
                    }
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.horizontal, 10)
                    
                    Spacer()
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        save()
                    }) {
                        Text(LocalizedStringKey("Next"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.black)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .navigationBarItems(leading: Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)
                })
                .onTapGesture {
                    endEditing(force: true)
                }
                .onAppear {
                    requestAppTrackingPermission()
                }
    }
    
    func save() {
        if !text.isEmpty {
            let analyticsProperties = ["Code": text]
            AnalyticsManager.shared.trackEvent(eventName: "Referrals", properties: analyticsProperties)
            AnalyticsManager.shared.updateUserAttributes(attributes: analyticsProperties)
        }
        onComplete()
    }
    
    func requestAppTrackingPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Permission granted, you can now access the IDFA.
                    print("Tracking authorized")
                case .denied:
                    // Permission denied.
                    print("Tracking denied")
                case .notDetermined:
                    // Permission hasn't been requested yet.
                    print("Tracking status not determined")
                case .restricted:
                    // Permission restricted.
                    print("Tracking restricted")
                @unknown default:
                    print("Unknown tracking status")
                }
            }
        } else {
            // Fallback for earlier iOS versions
            print("iOS version does not support App Tracking Transparency.")
        }
    }
}

extension View {
    func endEditing(force: Bool) {
#if os(iOS)
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.forEach { $0.endEditing(true) }
        #endif
    }
}
