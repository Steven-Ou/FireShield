import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var state: AppState
    var username: String

    init(username: String) {
        self.username = username

        // Tab bar styling to match your login theme
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.orange
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.orange]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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
                        .toolbarColorScheme(.dark, for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                }
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
            }
            .accentColor(.orange)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let base = URL(string: "http://127.0.0.1:8080/")!
    let mockState = AppState(api: ApiClient(baseURL: base))
    DashboardView(username: "Alex")
        .environmentObject(ViewRouter())
        .environmentObject(mockState)
}

