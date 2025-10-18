import SwiftUI

struct DashboardView: View {
    var username: String

    init(username: String) {
        self.username = username
        
        // Customize the appearance of the TabView
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        // Set colors for selected and unselected items
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.orange
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.orange]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            // Apply the fiery gradient to the entire background
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
                        Label("Chat", systemImage: "message.fill")
                    }

                // Wrap ProfileView in a NavigationView for the title
                NavigationView {
                    ProfileView(username: username)
                }
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
            }
            // Use an accent color that stands out on the tab bar
            .accentColor(.orange)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(username: "Alex")
    }
}
