import SwiftUI

struct TrendsView: View {
    @State private var readings: [VOCReading] = VOCReading.sampleData()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Weekly VOC Exposure Trends")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)

                    HStack(spacing: 12) {
                        SummaryCard(title: "Avg TVOC", value: String(format: "%.0f ppb", averageTVOC()), color: .orange)
                        SummaryCard(title: "Max TVOC", value: String(format: "%.0f ppb", maxTVOC()), color: .red)
                    }

                    HStack(spacing: 12) {
                        SummaryCard(title: "Avg Formaldehyde", value: String(format: "%.2f ppm", averageFormaldehyde()), color: .yellow)
                        SummaryCard(title: "Avg Benzene", value: String(format: "%.2f ppm", averageBenzene()), color: .blue)
                    }

                    Divider().padding(.vertical, 10)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(readings) { reading in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(reading.dateString).font(.headline)
                                Text("TVOC: \(Int(reading.tvoc_ppb)) ppb")
                                Text("Formaldehyde: \(String(format: "%.2f", reading.formaldehyde_ppm)) ppm")
                                Text("Benzene: \(String(format: "%.2f", reading.benzene_ppm)) ppm")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Trends")
        }
    }

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

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}

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

#Preview {
    TrendsView()
}
TrendsView.swift
4 KB
