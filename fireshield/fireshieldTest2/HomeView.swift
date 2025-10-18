import SwiftUI
import CoreHaptics

struct HomeView: View {
    @EnvironmentObject var state: AppState
    @State private var hours = 24
    @State private var engine: CHHapticEngine?

    // Local theme
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]),
        startPoint: .top, endPoint: .bottom
    )
    @ViewBuilder private func card(_ content: some View) -> some View {
        content.padding().background(.ultraThinMaterial).cornerRadius(15)
    }
    private func severityColor(_ s: String) -> Color {
        switch s.uppercased() {
        case "CRITICAL": return .red
        case "ELEVATED": return .orange
        case "SAFE":     return .green
        default:         return .gray
        }
    }

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Live Summary")
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundColor(.white).shadow(radius: 2)
                        .padding([.top, .horizontal])

                    HStack(spacing: 15) {
                        MetricCard(title: "TVOC (avg)",
                                   value: format(state.report?.avgTVOC, unit: "ppb"),
                                   color: .black)

                        card(
                            HStack {
                                Text((state.report?.severity ?? "—").uppercased())
                                    .font(.subheadline).bold()
                                    .padding(.horizontal, 10).padding(.vertical, 6)
                                    .background(severityColor(state.report?.severity ?? ""))
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                Spacer()
                                if let risk = state.report?.aiReport.riskScore {
                                    Text("Risk \(risk)").font(.headline).foregroundColor(.black)
                                }
                            }
                        )
                    }
                    .padding(.horizontal)

                    HStack(spacing: 15) {
                        MetricCard(title: "Max TVOC",
                                   value: format(state.report?.maxTVOC, unit: "ppb"),
                                   color: .black)
                        MetricCard(title: "% Critical",
                                   value: formatPct(state.report?.fracCritical),
                                   color: .black)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("24-Hour Exposure Trend")
                            .font(.headline).foregroundColor(.white).shadow(radius: 1)
                            .padding([.top, .horizontal])

                        RoundedRectangle(cornerRadius: 15)
                            .fill(.regularMaterial)
                            .frame(height: 180)
                            .overlay(Text("Graph coming soon…")
                                .foregroundColor(.black.opacity(0.6)))
                            .padding(.horizontal)
                    }

                    if state.report?.severity.uppercased() == "CRITICAL" {
                        HStack(spacing: 15) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow).font(.title)
                            VStack(alignment: .leading) {
                                Text("High VOC Levels Detected").fontWeight(.bold)
                                Text("Increase ventilation and start decon.").font(.subheadline)
                            }.foregroundColor(.white)
                        }
                        .padding().background(.black.opacity(0.4))
                        .cornerRadius(15).padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .onAppear { hapticPing() }
                    }

                    if let s = state.report?.aiReport.summary {
                        card(VStack(alignment: .leading, spacing: 8) {
                            Text("AI Summary").font(.headline)
                            Text(s)
                        }).padding(.horizontal)
                    }

                    if let err = state.lastError {
                        Text(err).foregroundColor(.white).padding(.horizontal)
                    }
                }
            }
        }
    }

    private func hapticPing() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            if engine == nil { engine = try CHHapticEngine(); try engine?.start() }
            let sharp = CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9),
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            ], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [sharp], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch { }
    }
}

struct MetricCard: View {
    var title: String
    var value: String
    var color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.headline).foregroundColor(.black.opacity(0.7))
            Text(value).font(.title2).fontWeight(.bold).foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding().background(.ultraThinMaterial).cornerRadius(15)
    }
}

private func format(_ v: Double?, unit: String) -> String { v.map { String(format:"%.0f %@", $0, unit) } ?? "—" }
private func formatPct(_ v: Double?) -> String { v.map { String(format:"%.0f%%", $0*100) } ?? "—" }

#Preview {
    let base = URL(string: "http://127.0.0.1:8080/")!
    let mock = AppState(api: ApiClient(baseURL: base))
    mock.report = InsightsReport(
        windowHours: 24,
        metrics: [
            "severity": AnyCodable("SAFE"),
            "avg_tvoc_ppb": AnyCodable(420.0),
            "max_tvoc_ppb": AnyCodable(910.0),
            "fraction_time_critical": AnyCodable(0.07)
        ],
        aiReport: .init(
            summary: "Levels trending down; complete routine decon.",
            riskScore: 28,
            keyFindings: ["Short peak earlier today", "Mostly below elevated threshold", "Downward slope last 6h"],
            recommendations: ["Vent bay 10–15 min", "Keep PPE out of quarters", "Wipe down surfaces"],
            deconChecklist: ["Open bay doors", "Bag PPE", "Shower within 1 hour"],
            policySuggestion: nil
        ),
        model: "gemini-2.5-flash",
        source: "fallback"
    )
    return HomeView().environmentObject(mock)
}
