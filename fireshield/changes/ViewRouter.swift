import SwiftUI
import Combine

class ViewRouter: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @Published var currentPage: Page

    init() {
        self.currentPage = hasCompletedOnboarding ? .login : .onboarding
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        withAnimation { currentPage = .login }
    }

    func goToOnboarding() {
        hasCompletedOnboarding = false
        withAnimation { currentPage = .onboarding }
    }
}

enum Page { case onboarding, login }
