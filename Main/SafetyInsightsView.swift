import SwiftUI

struct SafetyInsightsView: View {
    // This view should get the ViewRouter from the environment, not AppState
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        ZStack {
            // Added the fiery gradient background for consistency
            LinearGradient(
                gradient: Gradient(colors: [Color.red, Color.orange, .yellow]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("Safety Insights")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                        .padding(.bottom)
                    
                    // This section will eventually be powered by your AI backend.
                    // For now, it shows placeholder data styled to match the app.
                    InsightCard(
                        title: "Exposure Summary",
                        content: "Your average VOC exposure over the last 24 hours has been in the ELEVATED range. Consistent exposure at this level warrants attention.",
                        symbolName: "lungs.fill",
                        color: .orange
                    )
                    
                    InsightCard(
                        title: "Recommended Actions",
                        content: "• Ensure full gear decontamination after each call.\n• Increase ventilation in the apparatus bay.\n• Store personal gear away from living quarters.",
                        symbolName: "shield.lefthalf.filled",
                        color: .red
                    )
                    
                    InsightCard(
                        title: "Decon Reminder",
                        content: "Perform gross decon of your gear and shower within the hour after returning to the station to minimize take-home toxins.",
                        symbolName: "bubbles.and.sparkles.fill",
                        color: .blue
                    )
                }
                .padding()
            }
            .scrollContentBackground(.hidden) // Ensures the gradient shows through
        }
    }
}

// A helper view for styling the insight cards
struct InsightCard: View {
    let title: String
    let content: String
    let symbolName: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 15) {
                Image(systemName: symbolName)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            
            Text(content)
                .foregroundColor(.black.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}


struct SafetyInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        SafetyInsightsView()
            .environmentObject(ViewRouter())
    }
}

