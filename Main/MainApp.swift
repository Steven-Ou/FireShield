import SwiftUI

@main
struct MainApp: App {
    // This property wrapper reads the value we save in OnboardingView.
    // It will be 'false' by default.
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            // If the user has completed onboarding, show the LoginView.
            // Otherwise, show the OnboardingView.
            if hasCompletedOnboarding {
                LoginView()
            } else {
                OnboardingView()
            }
        }
    }
}

