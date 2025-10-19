import SwiftUI
import Charts

struct TVOCChart: View {
    let points: [TimePoint]

    var body: some View {
        Chart(points) { p in
            if let v = p.tvoc_ppb {
                LineMark(
                    x: .value("Time", p.ts),
                    y: .value("TVOC (ppb)", v)
                )
            }
        }
        .chartYAxisLabel("ppb")
        .frame(height: 220)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}
