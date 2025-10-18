import SwiftUI

struct LoginView: View {
    // This view owns the data, so we use @State
    @State private var isLoggedIn = false
    
    // State for the text fields and UI
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Fiery gradient background that covers the whole screen
            LinearGradient(
                gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // New fiery icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                // Added a shadow to lift the icon off the background
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                
                Text("Fire Shield")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black) // Text color set to black
                
                Text("Sign in to track your health")
                    .foregroundColor(.black.opacity(0.8)) // Subtly less prominent black
                
                VStack(spacing: 15) {
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(12)
                    // Using a semi-transparent material for the text fields
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
                        // Text color is now black for readability
                            .foregroundColor(.black)
                        // The button background adapts with a material effect
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
                .foregroundColor(.black) // Text color set to black
                
                Spacer()
            }
            .padding()
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
        
        // Simulate a network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            self.isLoggedIn = true
        }
    }
}

// The preview provider for ContentView
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
