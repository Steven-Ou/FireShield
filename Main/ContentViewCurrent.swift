import SwiftUI

struct ContentViewCurrent: View {
    @State private var isLoggedIn = false
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 🔥 Fiery gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // 🔥 Fire icon and header text
                    Image(systemName: "flame.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                        .padding(.bottom, 10)
                    
                    Text("Fire Shield")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("Your safety, monitored in real time.")
                        .foregroundColor(.black.opacity(0.8))
                        .padding(.bottom, 30)
                    
                    // 🧱 Login fields
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
                            .padding(.top, 8)
                    }
                    
                    // 🧭 Buttons aligned your way — login above sign-up
                    VStack(spacing: 15) {
                        if isLoading {
                            ProgressView()
                                .padding()
                        } else {
                            Button(action: handleLogin) {
                                Text("Log In")
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
                        
                        // ✅ Sign up button in your preferred spot (below Log In)
                        NavigationLink(destination: SignUpView()) {
                            Text("Don’t have an account? Sign Up")
                                .font(.footnote)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
            // Navigate to Dashboard after login
            .navigationDestination(isPresented: $isLoggedIn) {
                DashboardView(username: extractUsername(from: email))
            }
        }
    }
    
    func handleLogin() {
        isLoading = true
        errorMessage = ""
        
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in both email and password."
            isLoading = false
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            self.isLoggedIn = true
        }
    }
    
    func extractUsername(from email: String) -> String {
        email.split(separator: "@").first.map(String.init) ?? "User"
    }
}

#Preview {
    ContentViewCurrent()
}
