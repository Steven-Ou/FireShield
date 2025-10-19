import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var state: AppState
    var username: String

    init(username: String) {
        self.username = username

        // Tab bar styling to match your login theme
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.2)
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

    mockState.report = InsightsReport(
        windowHours: 24,
        metrics: [
            "severity": AnyCodable("ELEVATED"),
            "avg_tvoc_ppb": AnyCodable(780.0)
        ],
        aiReport: .init(
            summary: "Elevated VOCs with multiple spikes. Ventilate and complete decon.",
            riskScore: 72,
            keyFindings: ["Spikes above 900 ppb", "Upward trend in last 6h"],
            recommendations: ["Vent apparatus bay 30+ min", "Bag PPE outside quarters"],
            deconChecklist: ["Open bay doors", "Bag & isolate PPE", "Shower within 1 hour"],
            policySuggestion: "Adopt post-call ventilation SOP."
        ),
        model: "mock",
        source: "preview"
    )

    return DashboardView(username: "Alex")
        .environmentObject(ViewRouter())
        .environmentObject(mockState) // Pass the populated state
}
