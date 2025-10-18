import SwiftUI

struct DashboardView: View {
    var username: String

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            TrendsView()
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }

            ChatbotView()
                .tabItem {
                    Label("Chat", systemImage: "message")
                }

            ProfileView(username: username)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    DashboardView(username: "Alex")
}
