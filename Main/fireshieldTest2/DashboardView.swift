import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var state: AppState
    var username: String

    init(username: String) {
        self.username = username

        // Tab bar styling
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.orange
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.orange]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Navigation bar styling
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground() // Make it transparent
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // Set large title color
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Set small title color
        
        // Apply the appearance to all navigation bars
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]),
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            TabView {
                HomeView()
                    .environmentObject(state)
                    .tabItem { Label("Home", systemImage: "house.fill") }

                TrendsView()
                    .tabItem { Label("Trends", systemImage: "chart.line.uptrend.xyaxis") }

                SafetyInsightsView()
                    .environmentObject(state)
                    .tabItem { Label("Insights", systemImage: "list.bullet.clipboard.fill") }

                NavigationView {
                    ProfileView(username: username)
                        .navigationTitle("Profile")
                }
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
            }
            .accentColor(.orange)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let base = URL(string: "https://fireshield-tdpy.onrender.com/")!
    let mockState = AppState(api: ApiClient(baseURL: base))
    // Load mock data for all previews within the dashboard
    mockState.report = InsightsReport.mockReport()
    
    return DashboardView(username: "Alex")
        .environmentObject(ViewRouter())
        .environmentObject(mockState)
}

