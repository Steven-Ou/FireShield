import SwiftUI
import Combine

class ViewRouter: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @Published var currentPage: Page

    init() {
        // Give currentPage a default value before using other properties.
        self.currentPage = .onboarding
        
        // Now, check the saved value and update currentPage if needed.
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
    
    func goToOnboarding() {
        hasCompletedOnboarding = false
        withAnimation {
            currentPage = .onboarding
        }
    }
}

enum Page {
    case onboarding
    case login
}
