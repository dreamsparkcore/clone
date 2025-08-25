import SwiftUI

struct Root: View {
    @State private var navigationPath = NavigationPath()
    @State private var realFirst = false
    
    @State private var selectedYear = 2005  // Changed default to 2005
    @State private var isAnimating = false
    let currentYear = Calendar.current.component(.year, from: Date())
    let hapticImpact = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { geometry in
            
                                       VStack(spacing: 20) {
                                           Image("calai")
                                               .resizable()
                                               .scaledToFit()
                                               .frame(height: 40, alignment: .center)
                                               .padding(.bottom, -15)
                                           
                                           
                                           Spacer()
                                           
                                           HStack {
                                               VStack(alignment: .leading, spacing: 35) {
                                                   Text(LocalizedStringKey("Welcome!"))
                                                       .font(.title)
                                                       .fontWeight(.bold)
                                                       .foregroundColor(.black)
                                                       .padding(.bottom, -15)
                                                   Text(LocalizedStringKey("Let's start by finding out more about your health goals."))
                                                       .font(.headline)
                                                       .fontWeight(.semibold)
                                                       .foregroundColor(.black)
                                                       .padding(.trailing, 50)
                                                   
                                                   Image("magictest")
                                                       .resizable()
                                                       .scaledToFit()
                                                       .frame(width: 100)
                                               }
                                               Spacer()
                                           }
                                           .padding()
                                           
                                           Spacer()
                                           VStack {
                                               // Buttons
                                               Button {
                                                   UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                   navigationPath.append(ViewType.onboarding)
                                               } label: {
                                                   HStack {
                                                       Spacer()
                                                       ZStack {
                                                           RoundedRectangle(cornerRadius: 25, style: .continuous)
                                                               .fill(.black)
                                                               .frame(height: 50)
                                                           
                                                           HStack {
                                                               Text(LocalizedStringKey("Start Quiz"))
                                                                   .fontWeight(.bold)
                                                                   .font(.headline)
                                                                   .foregroundColor(.white)
                                                               
                                                               Image(systemName: "chevron.right.circle.fill")
                                                                   .resizable()
                                                                   .scaledToFit()
                                                                   .frame(width: 22.5)
                                                                   .foregroundColor(.white)
                                                           }
                                                           .padding(.horizontal, 20)
                                                       }
                                                       .frame(height: 50)
                                                       .fixedSize(horizontal: true, vertical: false)
                                                   }
                                                   .padding(.bottom, 50)
                                                   .padding(.trailing)
                                               }
                                           }
                                           
                                       }
                                       .padding()
                                       .frame(width: geometry.size.width, height: geometry.size.height)
                                   }
                                   .background(Color(.systemGroupedBackground))
            .onAppear {
                AnalyticsManager.shared.trackEvent(eventName: "onboarding_screen_0")
            }
            .navigationDestination(for: ViewType.self) { viewType in
                switch viewType {
                case .onboarding:
                        OnboardingView(onComplete: {
                            navigationPath.append(ViewType.goals)
                            AnalyticsManager.shared.trackEvent(eventName: "onboarding_auth_success")
                            
                        })
                        .navigationBarBackButtonHidden()
                        .onAppear {
                            AnalyticsManager.shared.trackEvent(eventName: "onboarding_screen_1")
                        }
                    
                case .goals:
                    GoalSelectView(onComplete: {
                        navigationPath.append(ViewType.calculate)
                    })
                    .navigationBarBackButtonHidden()
                    .onAppear {
                        AnalyticsManager.shared.trackEvent(eventName: "onboarding_screen_8")
                    }
                    
                case .calculate:
                    InitialCalcView(onComplete: {
                        navigationPath.append(ViewType.review)
                    })
                    .navigationBarBackButtonHidden()
                    .onAppear {
                        AnalyticsManager.shared.trackEvent(eventName: "onboarding_screen_8")
                    }
                case .referral:
                    ReferralCodeView(onComplete: {
                        navigationPath.append(ViewType.review)
                    })
                    .navigationBarBackButtonHidden()
                    .onAppear {
                        AnalyticsManager.shared.trackEvent(eventName: "onboarding_screen_9")
                    }
                    
                case .review:
                    ReviewScreenView(onComplete: {
                        navigationPath.append(ViewType.finalcalc)
                    })
                    .navigationBarBackButtonHidden()
                    .onAppear {
                        AnalyticsManager.shared.trackEvent(eventName: "onboarding_screen_10")
                    }
                    
                case .finalcalc:
                    FinalCalculateView(calc: true, onComplete: {
                        NavigationManager.shared.presentView(PaywallView(onComplete: {
                            
                        }))
                    })
                    .onAppear {
                        AnalyticsManager.shared.trackEvent(eventName: "onboarding_screen_11")
                    }
                case .paywall:
                    PaywallView(onComplete: {
                        
                    })
                        .navigationBarBackButtonHidden()
                        .onAppear {
                            AnalyticsManager.shared.trackEvent(eventName: "onboarding_screen_12")
                        }
                }
            }
        }
    }
}

enum ViewType: Hashable {
    case onboarding
    case goals
    case calculate
    case referral
    case review
    case finalcalc
    case paywall
}
