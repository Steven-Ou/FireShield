import SwiftUI

struct HomeView: View {
    @State private var tvoc: Double = 450.0
    @State private var formaldehyde: Double = 0.08
    @State private var benzene: Double = 0.03
    @State private var airQualityStatus: String = "Elevated"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Live Summary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    .padding([.top, .horizontal])
                
                HStack(spacing: 15) {
                    MetricCard(title: "TVOC", value: "\(Int(tvoc)) ppb", color: .orange)
                    MetricCard(title: "Status", value: airQualityStatus, color: airQualityStatus == "Safe" ? .green : .yellow)
                }
                .padding(.horizontal)
                
                HStack(spacing: 15) {
                    MetricCard(title: "Formaldehyde", value: String(format: "%.2f ppm", formaldehyde), color: .white)
                    MetricCard(title: "Benzene", value: String(format: "%.2f ppm", benzene), color: .white)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("24-Hour Exposure Trend")
                        .font(.headline)
                        .foregroundColor(.white)
                        .shadow(radius: 1)
                        .padding([.top, .horizontal])
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.regularMaterial)
                        .frame(height: 180)
                        .overlay(
                            Text("Graph coming soon...")
                                .foregroundColor(.black.opacity(0.6))
                        )
                        .padding(.horizontal)
                }
                
                // Alert section for elevated VOCs
                if tvoc > 400 {
                    HStack(spacing: 15) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text("High VOC Levels Detected")
                                .fontWeight(.bold)
                            Text("Consider increasing ventilation and checking gear.")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                    }
                    .padding()
                    .background(.black.opacity(0.4))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
    }
}

// Redesigned MetricCard to use the material effect
struct MetricCard: View {
    var title: String
    var value: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
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
        .cornerRadius(15)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
