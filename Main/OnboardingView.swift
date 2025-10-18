import SwiftUI

struct OnboardingView: View {
    let slides: [Slide] = Slide.sampleSlides()
    @Binding var currentPage: Int

    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentPage) {
                ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                    OnboardingSlideView(slide: slide)
                        .tag(index)
                        .padding(.vertical, 6)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 260)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .padding(.horizontal)
            .shadow(radius: 4)
        }
    }
}

#Preview {
    StatefulPreviewWrapper(0) { binding in
        OnboardingView(currentPage: binding)
            .previewLayout(.sizeThatFits)
    }
}
