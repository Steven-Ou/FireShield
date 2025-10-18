import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewRouter: ViewRouter

    var body: some View {
        TabView {
            OnboardingCardView(
                systemImageName: "exclamationmark.triangle.fill",
                title: "The Invisible Threat",
                description: "After a fire, gear and stations remain contaminated with toxic VOCs like benzene and formaldehyde, posing long-term cancer risks."
            )
            OnboardingCardView(
                systemImageName: "shield.lefthalf.filled",
                title: "FireShield VOC",
                description: "Our platform helps you visualize and understand your exposure, making the invisible visible."
            )
            OnboardingCardView(
                systemImageName: "chart.bar.xaxis",
                title: "Track Your Exposure",
                description: "See real-time exposure, get alerts for elevated readings, and track trends to stay informed.",
                isLastPage: true,
                onGetStarted: { viewRouter.completeOnboarding() }
            )
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]),
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        )
    }
}

struct OnboardingCardView: View {
    let systemImageName: String
    let title: String
    let description: String
    var isLastPage: Bool = false
    var onGetStarted: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImageName)
                .font(.system(size: 80))
                .foregroundColor(.white)
                .shadow(radius: 5)
            Text(title).font(.largeTitle).fontWeight(.bold).foregroundColor(.white)
            Text(description)
                .font(.body).multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal)

            if isLastPage {
                Button(action: { onGetStarted?() }) {
                    Text("Get Started")
                        .font(.headline).fontWeight(.semibold)
                        .padding().frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .background(.regularMaterial)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .padding(.horizontal, 40)
            }
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
        .environmentObject(ViewRouter())
}
