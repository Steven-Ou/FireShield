import SwiftUI

struct OnboardingSlideView: View {
    let slide: Slide

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: slide.symbolName)
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundColor(.black)
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(radius: 3)

            Text(slide.title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 6)

            Text(slide.description)
                .font(.body)
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer(minLength: 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingSlideView(slide: Slide.sampleSlides()[0])
        .previewLayout(.sizeThatFits)
}
