import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var report: InsightsReport?
    @Published var lastError: String?
    @Published var isCritical = false

    let api: ApiClient
    private var timer: AnyCancellable?

    init(api: ApiClient) {
        self.api = api
        self.isAuthenticated = (api.token != nil)
    }

    func startPolling(hours: Int = 24, every seconds: TimeInterval = 20) {
        stopPolling()
        timer = Timer.publish(every: seconds, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in Task { await self?.refresh(hours: hours) } }
    }

    func stopPolling() { timer?.cancel(); timer = nil }

    func refresh(hours: Int = 24) async {
        do {
            let r = try await api.fetchReport(hours: hours)
            report = r
            isCritical = r.severity.uppercased() == "CRITICAL"
            lastError = nil
        } catch ApiClient.AuthError.unauthorized {
            isAuthenticated = false; stopPolling()
        } catch {
            lastError = "Network error. Pull to retry."
        }
    }

    func logout() {
        api.token = nil
        isAuthenticated = false
        report = nil
        stopPolling()
    }
}
