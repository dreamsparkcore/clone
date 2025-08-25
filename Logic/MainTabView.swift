import SwiftUI

enum MainTabs: Int, CaseIterable {
    case home, analytics, menu
    
    var imageName: String {
        switch self {
        case .home: return "grid"
        case .analytics: return "chart"
        case .menu: return "menu"
        }
    }
    
    var title: String {
        String(describing: self).capitalized
    }
}

struct MainTabView: View {
    @StateObject private var navManager = NavigationManager.shared
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                TabView(selection: $navManager.selectedTab) {
                    HomeView()
                        .tag(MainTabs.home)

                    AnalyticsView()
                        .tag(MainTabs.analytics)
                    
                    MenuView()
                        .tag(MainTabs.menu)
                }
             
                customTabBar
                .frame(height: 50)
                .background(Color.white)
            }
        }
    }

    private var customTabBar: some View {
        HStack {
            ForEach(MainTabs.allCases, id: \.self) { tab in
                tabButton(tab: tab)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 10)
    }
    
    
    
    private func tabButton(tab: MainTabs) -> some View {
        Button(action: { selectTab(tab) }) {
            Image(tab.imageName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .fontWeight(.bold)
                .frame(width: 30, height: 30)
                .foregroundStyle(navManager.selectedTab == tab ? Color.primary : Color.gray)
        }
        .buttonStyle(.plain)
    }
    
    private func selectTab(_ tab: MainTabs) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        navManager.selectedTab = tab
    }
    
    private func selectRecoveryTab() {
        selectTab(.analytics)
    }
}
