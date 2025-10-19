import SwiftUI
import Charts

struct HomeView: View {
    @EnvironmentObject var state: AppState
    @State private var didLoad = false

    // Background theme
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]),
        startPoint: .top, endPoint: .bottom
    )

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    Text("Live Summary")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                        .padding([.top, .horizontal])

                    // Metrics row: Avg TVOC + Severity/Risk chip
                    HStack(spacing: 15) {
                        MetricCard(title: "TVOC (avg)",
                                   value: format(state.report?.avgTVOC, unit: "ppb"),
                                   color: .black)

                        infoChip
                    }
                    .padding(.horizontal)

                    // More metrics: Max TVOC + % Critical
                    HStack(spacing: 15) {
                        MetricCard(title: "Max TVOC",
                                   value: format(state.report?.maxTVOC, unit: "ppb"),
                                   color: .black)
                        MetricCard(title: "% Critical",
                                   value: formatPct(state.report?.fracCritical),
                                   color: .black)
                    }
                    .padding(.horizontal)

                    // Chemicals row: Formaldehyde + Benzene
                    HStack(spacing: 15) {
                        MetricCard(title: "Formaldehyde (avg)",
                                   value: format(state.report?.metrics["avg_formaldehyde_ppm"]?.value as? Double, unit: "ppm"),
                                   color: .black)
                        MetricCard(title: "Benzene (avg)",
                                   value: format(state.report?.metrics["avg_benzene_ppm"]?.value as? Double, unit: "ppm"),
                                   color: .black)
                    }
                    .padding(.horizontal)

                    // Trend chart
                    VStack(alignment: .leading) {
                        Text("\(state.report?.windowHours ?? 24)-Hour Exposure Trend")
                            .font(.headline)
                            .foregroundColor(.black)
                            .shadow(radius: 1)
                            .padding([.top, .horizontal])

                        Chart(state.series) { p in
                            if let v = p.tvoc_ppb {
                                LineMark(
                                    x: .value("Time", p.ts),
                                    y: .value("TVOC (ppb)", v)
                                )
                            }
                        }
                        .chartYAxisLabel("ppb")
                        .frame(height: 220)
                        .padding(.horizontal)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }

                    // Critical alert banner (optional)
                    if state.report?.severity.uppercased() == "CRITICAL" {
                        HStack(spacing: 15) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                                .font(.title)
                            VStack(alignment: .leading) {
                                Text("High VOC Levels Detected").bold()
                                Text("Increase ventilation and start decon.")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white)
                        }
                        .padding()
                        .background(.black.opacity(0.4))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Short AI summary (from aiReport)
                    if let s = state.report?.aiReport.summary {
                        card(
                            VStack(alignment: .leading, spacing: 8) {
                                Text("AI Summary").font(.headline)
                                Text(s)
                            }
                            .foregroundColor(.black)
                        )
                        .padding(.horizontal)
                    }

                    // Error message (if any)
                    if let err = state.lastError {
                        Text(err)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear {
            guard !didLoad else { return }
            didLoad = true
            Task { await state.refresh(hours: 24) }
        }
    }

    // MARK: - Subviews & helpers

    private var infoChip: some View {
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
                    Text("Risk \(risk)")
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
        )
    }

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
}

// MARK: - Metric card

struct MetricCard: View {
    var title: String
    var value: String
    var color: Color
    var body: some View {
        VStack(spacing: 5) {
            Text(title).font(.headline).foregroundColor(.black.opacity(0.7))
            Text(value).font(.title2).fontWeight(.bold).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding().background(.ultraThinMaterial).cornerRadius(15)
    }
}

// MARK: - Formatters

private func format(_ v: Double?, unit: String) -> String {
    v.map { String(format: "%.0f %@", $0, unit) } ?? "—"
}

private func formatPct(_ v: Double?) -> String {
    v.map { String(format: "%.0f%%", $0 * 100) } ?? "—"
}
