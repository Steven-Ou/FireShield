import SwiftUI

struct SafetyInsightsView: View {
    @EnvironmentObject var state: AppState

    // LOCAL THEME
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]),
        startPoint: .top, endPoint: .bottom
    )
    @ViewBuilder private func card(_ content: some View) -> some View {
        content.padding().background(.ultraThinMaterial).cornerRadius(12)
    }

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Safety Insights")
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundColor(.white).shadow(radius: 2)
                        .padding([.top, .horizontal])

                    if let summary = state.report?.aiReport.summary {
                        card(VStack(alignment: .leading, spacing: 8) {
                            Text("Summary").font(.headline)
                            Text(summary)
                        }).padding(.horizontal)
                    }

                    if let f = state.report?.aiReport.keyFindings, !f.isEmpty {
                        BulletCard(title: "Key Findings", bullets: f)
                    }

                    if let r = state.report?.aiReport.recommendations, !r.isEmpty {
                        BulletCard(title: "Recommendations", bullets: r)
                    }

                    if let d = state.report?.aiReport.deconChecklist, !d.isEmpty {
                        ChecklistCard(title: "Decon Checklist", items: d)
                    }

                    if let p = state.report?.aiReport.policySuggestion, !p.isEmpty {
                        card(VStack(alignment: .leading, spacing: 8) {
                            Text("Policy Suggestion").font(.headline)
                            Text(p)
                        }).padding(.horizontal)
                    }

                    if let err = state.lastError {
                        Text(err).foregroundColor(.white).padding(.horizontal)
                    }

                    Spacer(minLength: 12)
                }
            }
        }
        .navigationTitle("Safety Insights")
    }
}

struct BulletCard: View {
    let title: String
    let bullets: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ForEach(bullets.prefix(5), id: \.self) { b in
                HStack(alignment: .top) { Text("•"); Text(b) }
            }
        }
        .padding().background(.ultraThinMaterial).cornerRadius(12)
        .padding(.horizontal)
    }
}

struct ChecklistCard: View {
    let title: String
    let items: [String]
    @State private var done: Set<Int> = []
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ForEach(Array(items.enumerated()), id: \.0) { idx, text in
                Button {
                    if done.contains(idx) { done.remove(idx) } else { done.insert(idx) }
                } label: {
                    HStack {
                        Image(systemName: done.contains(idx) ? "checkmark.circle.fill" : "circle")
                        Text(text)
                    }
                }.buttonStyle(.plain)
            }
        }
        .padding().background(.ultraThinMaterial).cornerRadius(12)
        .padding(.horizontal)
    }
}
