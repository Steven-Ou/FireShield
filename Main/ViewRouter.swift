import SwiftUI
import Combine

// This class will now be the single source of truth for navigation.
class ViewRouter: ObservableObject {
    
    // 1. The router now reads and writes to AppStorage.
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    // 2. The current page is determined by the stored value when the app starts.
    @Published var currentPage: Page

    init() {
        if hasCompletedOnboarding {
            currentPage = .login
        } else {
            currentPage = .onboarding
        }
    }
    
    // 3. This function transitions to the login page AND saves the state permanently.
    func completeOnboarding() {
        hasCompletedOnboarding = true
        withAnimation {
            currentPage = .login
        }
    }
    
    // 4. (Optional) A helper for development to reset the onboarding flow.
    func goToOnboarding() {
        hasCompletedOnboarding = false
        withAnimation {
            currentPage = .onboarding
        }
    }
}

// An enum to define the different pages in our app.
enum Page {
    case onboarding
    case login
}
