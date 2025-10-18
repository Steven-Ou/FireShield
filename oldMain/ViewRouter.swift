import SwiftUI
import Combine

class ViewRouter: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    @Published var currentPage: Page
    
    // Store the logged-in user's name to pass to the dashboard.
    @Published var loggedInUserName: String?

    init() {
        self.currentPage = .onboarding
        if hasCompletedOnboarding {
            self.currentPage = .login
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        withAnimation {
            currentPage = .login
        }
    }
    
    // This function is called upon a successful login.
    func loginSuccess(userName: String) {
        loggedInUserName = userName
        withAnimation {
            currentPage = .dashboard
        }
    }
    
    func goToOnboarding() {
        hasCompletedOnboarding = false
        withAnimation {
            currentPage = .onboarding
        }
    }
}

// Add the new .dashboard case to our Page enum.
enum Page {
    case onboarding
    case login
    case dashboard
}

