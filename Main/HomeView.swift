import SwiftUI
import Charts // optional: only if you plan to use charts later

struct HomeView: View {
    @State private var tvoc: Double = 120.0
    @State private var formaldehyde: Double = 0.04
    @State private var benzene: Double = 0.01
    @State private var airQualityStatus: String = "Safe"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 🔥 App header
                Text("Air Quality Summary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding(.top, 10)
                
                // 🧾 Cards showing data metrics
                HStack(spacing: 15) {
                    MetricCard(title: "TVOC", value: "\(Int(tvoc)) ppb", color: .orange)
                    MetricCard(title: "Formaldehyde", value: String(format: "%.2f ppm", formaldehyde), color: .yellow)
                }
                
                HStack(spacing: 15) {
                    MetricCard(title: "Benzene", value: String(format: "%.2f ppm", benzene), color: .blue)
                    MetricCard(title: "Status", value: airQualityStatus, color: airQualityStatus == "Safe" ? .green : .red)
                }
                
                // 📈 Graph placeholder (to add simulated data chart later)
                VStack(alignment: .leading) {
                    Text("24-hour Exposure Trend")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemGray6))
                        .frame(height: 180)
                        .overlay(
                            Text("Graph coming soon...")
                                .foregroundColor(.gray)
                        )
                }
                .padding(.top, 10)
                
                // 🚨 Alert section (for elevated VOCs)
                if tvoc > 800 {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text("High VOC levels detected! Move to fresh air immediately.")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color(.systemRed).opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

// MARK: - MetricCard subview
struct MetricCard: View {
    var title: String
    var value: String
    var color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

#Preview {
    HomeView()
}
