import SwiftUI

// This class will manage the navigation state of our app.
class ViewRouter: ObservableObject {
    // @Published will notify any views watching this property when it changes.
    @Published var currentPage: Page = .onboarding
}

// An enum to define the different pages in our app.
enum Page {
    case onboarding
    case login
}

