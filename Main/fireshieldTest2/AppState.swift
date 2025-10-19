import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var report: InsightsReport?
    @Published var series: [TimePoint] = []
    @Published var lastError: String?
    @Published var isCritical = false

    let api: ApiClient
    private var timer: AnyCancellable?

    init(api: ApiClient) {
        self.api = api
        self.isAuthenticated = (api.token != nil)
    }

    // Start a poller for the dashboard (e.g., every 20s)
    func startPolling(hours: Int = 24, every seconds: TimeInterval = 20) {
        stopPolling()
        timer = Timer.publish(every: seconds, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                Task { await self?.refresh(hours: hours) }
            }
    }

    func stopPolling() { timer?.cancel(); timer = nil }

    // Pull both report and series in one go
    func refresh(hours: Int = 24) async {
        do {
            let r = try await api.fetchReport(hours: hours)
            report = r
            isCritical = r.severity.uppercased() == "CRITICAL"
            lastError = nil

            // Fetch series for the same window (hourly buckets are nice for 24h)
            let pts = try await api.fetchSeries(hours: hours, bucket: "hour")
            series = pts

        } catch ApiClient.AuthError.unauthorized {
            isAuthenticated = false
            stopPolling()
        } catch let e as ClientError {
            lastError = e.localizedDescription
        } catch {
            lastError = error.localizedDescription
        }
    }

    func logout() {
        api.token = nil
        isAuthenticated = false
        report = nil
        series = []
        stopPolling()
    }
}
