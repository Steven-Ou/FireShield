import SwiftUI

struct LoginView: View {
    // Add this line to receive the ViewRouter from the environment.
    @EnvironmentObject var viewRouter: ViewRouter
    
    // Create an instance of our new authentication service.
    private let authService = AuthService()
    
    // State for the text fields and UI
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                
                Text("Fire Shield")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Sign in to track your health")
                    .foregroundColor(.black.opacity(0.8))
                
                VStack(spacing: 15) {
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
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
                    ProgressView()
                        .padding()
                } else {
                    Button(action: handleLogin) {
                        Text("Sign In")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .background(.regularMaterial)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button("Don't have an account? Sign Up") {
                    // Action for signing up
                }
                .font(.footnote)
                .foregroundColor(.black)
                
                Spacer()
            }
            .padding()
            
            // Go Back Button Overlay
            VStack {
                HStack {
                    Button(action: {
                        viewRouter.goToOnboarding()
                    }) {
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
    
    // This function is now async to handle the network request.
    func handleLogin() {
        isLoading = true
        errorMessage = ""
        
        // Use a Task to run our asynchronous network call.
        Task {
            do {
                let authResponse = try await authService.login(email: email, password: password)
                
                // On success, update the UI on the main thread.
                DispatchQueue.main.async {
                    isLoading = false
                    // Tell the ViewRouter that login was successful.
                    viewRouter.loginSuccess(userName: authResponse.displayName)
                }
            } catch {
                // On failure, update the UI on the main thread.
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = "Invalid email or password. Please try again."
                }
            }
        }
    }
}

// The preview provider remains the same.
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(ViewRouter())
    }
}

