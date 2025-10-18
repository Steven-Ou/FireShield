import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var isLoggedIn = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 🔥 Background gradient
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
                    
                    Text("FireShield")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("Log in to continue")
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
                    
                    NavigationLink("Don't have an account? Sign Up", value: "signup")
                        .font(.footnote)
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: $isLoggedIn) {
                    DashboardView(username: email)
                }
            }
        }
    }
    
    func handleLogin() {
        isLoading = true
        errorMessage = ""
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in both fields."
            isLoading = false
            return
        }
        
        // Simulate login delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            isLoggedIn = true
        }
    }
}

#Preview {
    LoginView()
}
