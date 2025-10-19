import SwiftUI

@main
struct MainApp: App {
    @StateObject private var viewRouter = ViewRouter()
    @StateObject private var state: AppState

    init() {
        let base = URL(string: "https://fireshield-tdpy.onrender.com/")!
        let api  = ApiClient(baseURL: base)
        _state = StateObject(wrappedValue: AppState(api: api))
    }

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if viewRouter.hasCompletedOnboarding {
                    if state.isAuthenticated {
                        DashboardView(username: "Firefighter")
                            .environmentObject(viewRouter)
                            .environmentObject(state)
                    } else {
                        LoginView()
                            .environmentObject(viewRouter)
                            .environmentObject(state)
                    }
                } else {
                    OnboardingView().environmentObject(viewRouter)
                }
            }
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .active:   if state.isAuthenticated { state.startPolling() }
                case .inactive, .background: state.stopPolling()
                @unknown default: break
                }
            }
        }
    }
}
