import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var state: AppState
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]),
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                
                Text("Fire Shield").font(.largeTitle).fontWeight(.bold).foregroundColor(.black)
                Text("Sign in to track your health").foregroundColor(.black.opacity(0.8))
                
                VStack(spacing: 15) {
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    
                    SecureField("Password", text: $password)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(8)
                        .background(.black.opacity(0.5))
                        .cornerRadius(8)
                }
                
                if isLoading {
                    ProgressView().padding()
                } else {
                    Button(action: handleLogin) {
                        Text("Sign In")
                            .font(.headline).fontWeight(.semibold)
                            .padding().frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .background(.regularMaterial)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button("Don't have an account? Sign Up") { }
                    .font(.footnote).foregroundColor(.black)
                
                Spacer()
            }
            .padding()
            
            // Back to onboarding button
            VStack {
                HStack {
                    Button(action: { viewRouter.goToOnboarding() }) {
                        Image(systemName: "arrow.backward.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.black.opacity(0.6))
                            .padding()
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
    private func handleLogin() {
        isLoading = true; errorMessage = ""
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in both email and password."
            isLoading = false; return
        }
        Task {
            defer { isLoading = false }
            do {
                // 1. Capture the login response
                let authResponse = try await state.api.login(email: email, password: password)
                
                // 2. Save the token to the ApiClient
                state.api.token = authResponse.token
                
                // 3. Update the app state
                state.isAuthenticated = true
                await state.refresh()     // This will now be an authenticated request
                state.startPolling()
            } catch {
                errorMessage = "Invalid email or password."
            }
        }
    }
}
#Preview {
    let base = URL(string: "https://fireshield-tdpy.onrender.com/")!
    let mockState = AppState(api: ApiClient(baseURL: base))
    LoginView()
        .environmentObject(ViewRouter())
        .environmentObject(mockState)
}
