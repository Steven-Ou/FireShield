import SwiftUI

struct DashboardView: View {
    var username: String
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                TrendsView()
                    .tabItem {
                        Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                    }
                
                SafetyInsightsView()
                    .tabItem {
                        Label("Insights", systemImage: "brain.head.profile")
                    }
                
                ProfileView(username: username)
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle.fill")
                    }
            }
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                
                appearance.stackedLayoutAppearance.normal.iconColor = .white
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
                
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor.orange
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.orange]
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(username: "Test User")
            .environmentObject(ViewRouter())
    }
}

