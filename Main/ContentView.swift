import SwiftUI

struct ContentView: View {
    @State private var showLogin = false
    @State private var showSignup = false
    @State private var currentPage = 0

    let slides = [
        "Welcome to FireShield — protecting firefighters from invisible risks.",
        "Monitor your VOC exposure in real time after every call.",
        "Track long-term exposure trends and learn safe decon practices.",
        "Join the mission to keep our heroes safe from toxic environments."
    ]

    var body: some View {
        NavigationView {
            VStack {
                // 🔥 Header
                Text("🔥 FireShield")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding(.top, 50)

                Spacer()

                // 🖼️ Slide content
                TabView(selection: $currentPage) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Text(slides[index])
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding()
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 300)

                Spacer()

                // 🔘 Buttons
                VStack(spacing: 15) {
                    NavigationLink(destination: LoginView()) {
                        Text("Log In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: SignupView()) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
