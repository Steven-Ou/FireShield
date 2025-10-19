import SwiftUI
import Combine

class ViewRouter: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @Published var currentPage: Page
    @Published var loggedInUserName: String?

    init() {
        self.currentPage = .onboarding            // initialize first
        if hasCompletedOnboarding { currentPage = .login }  // then read @AppStorage
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        withAnimation { currentPage = .login }
    }

    func loginSuccess(userName: String) {
        loggedInUserName = userName
        withAnimation {
            currentPage = .dashboard
        }
    }

    func goToOnboarding() {
        hasCompletedOnboarding = false
        withAnimation { currentPage = .onboarding }
    }
}

enum Page { case onboarding, login, dashboard }
