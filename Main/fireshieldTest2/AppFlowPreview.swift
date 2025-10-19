import SwiftUI

// This view simulates the main app's logic just for the preview canvas.
struct AppFlowPreview: View {
    // It creates and holds its own ViewRouter for the preview.
    @StateObject private var viewRouter = ViewRouter()
    @StateObject private var state: AppState

    init() {
        let base = URL(string: "https://fireshield-tdpy.onrender.com/")!
        let api  = ApiClient(baseURL: base)
        _state = StateObject(wrappedValue: AppState(api: api))
    }

    var body: some View {
        // This switch statement is the same as in your MainApp.swift.
        // It swaps the views based on the router's state.
        switch viewRouter.currentPage {
        case .onboarding:
            OnboardingView()
                .environmentObject(viewRouter)
        case .login:
            LoginView()
                .environmentObject(viewRouter)
                .environmentObject(state)
        case .dashboard:
            // For the preview, we can just show a sample dashboard
            DashboardView(username: "Test User")
                .environmentObject(viewRouter)
                .environmentObject(state)
        }
    }
}

// The PreviewProvider tells Xcode to display our interactive AppFlowPreview.ª
struct AppFlowPreview_Previews: PreviewProvider {
    static var previews: some View {
        AppFlowPreview()
    }
}
