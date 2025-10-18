import SwiftUI

struct TrendsView: View {
    @State private var readings: [VOCReading] = VOCReading.sampleData()

    var body: some View {
        // Use a ZStack to layer the gradient behind the content
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Weekly VOC Exposure")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                        .padding([.top, .horizontal])

                    HStack(spacing: 15) {
                        SummaryCard(title: "Avg TVOC", value: String(format: "%.0f ppb", averageTVOC()), color: .black)
                        SummaryCard(title: "Max TVOC", value: String(format: "%.0f ppb", maxTVOC()), color: .black)
                    }
                    .padding(.horizontal)

                    HStack(spacing: 15) {
                        SummaryCard(title: "Avg Formaldehyde", value: String(format: "%.2f ppm", averageFormaldehyde()), color: .black)
                        SummaryCard(title: "Avg Benzene", value: String(format: "%.2f ppm", averageBenzene()), color: .black)
                    }
                    .padding(.horizontal)

                    Divider()
                        .background(Color.white.opacity(0.5))
                        .padding()

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(readings) { reading in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(reading.dateString).font(.headline)
                                Text("TVOC: \(Int(reading.tvoc_ppb)) ppb")
                                Text("Formaldehyde: \(String(format: "%.2f", reading.formaldehyde_ppm)) ppm")
                                Text("Benzene: \(String(format: "%.2f", reading.benzene_ppm)) ppm")
                            }
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // Helper functions remain the same
    func averageTVOC() -> Double {
        readings.map { $0.tvoc_ppb }.reduce(0, +) / Double(readings.count)
    }

    func maxTVOC() -> Double {
        readings.map { $0.tvoc_ppb }.max() ?? 0
    }

    func averageFormaldehyde() -> Double {
        readings.map { $0.formaldehyde_ppm }.reduce(0, +) / Double(readings.count)
    }

    func averageBenzene() -> Double {
        readings.map { $0.benzene_ppm }.reduce(0, +) / Double(readings.count)
    }
}

// Updated SummaryCard to use material background
struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black.opacity(0.7))
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}

// VOCReading struct remains the same
struct VOCReading: Identifiable {
    let id = UUID()
    let date: Date
    let tvoc_ppb: Double
    let formaldehyde_ppm: Double
    let benzene_ppm: Double

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    static func sampleData() -> [VOCReading] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            return VOCReading(
                date: date,
                tvoc_ppb: Double.random(in: 200...1200),
                formaldehyde_ppm: Double.random(in: 0.01...0.15),
                benzene_ppm: Double.random(in: 0.01...0.05)
            )
        }.reversed()
    }
}

struct TrendsView_Previews: PreviewProvider {
    static var previews: some View {
        TrendsView()
    }
}

