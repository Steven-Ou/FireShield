import SwiftUI

@main
struct MainApp: App {
    // Create an instance of our ViewRouter that the whole app can use.
    @StateObject var viewRouter = ViewRouter()

    var body: some Scene {
        WindowGroup {
            // Use a switch statement to show the correct view based on the router's state.
            switch viewRouter.currentPage {
            case .onboarding:
                OnboardingView()
                    .environmentObject(viewRouter)
            case .login:
                LoginView()
                    .environmentObject(viewRouter)
            case .dashboard:
                // When logged in, show the DashboardView.
                if let userName = viewRouter.loggedInUserName {
                    DashboardView(username: userName)
                        // Pass the router down to the dashboard so its children can use it
                        .environmentObject(viewRouter)
                } else {
                    // Fallback to login if the username is somehow nil
                    LoginView()
                        .environmentObject(viewRouter)
                }
            }
        }
    }
}

