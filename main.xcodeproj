import SwiftUI

/// A view that provides a user interface for signing in.
struct LoginView: View {
    // This binding is passed from the parent view (ContentView).
    // When we set its value to `true`, the parent view will dismiss this screen.
    @Binding var isLoggedIn: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // App Icon and Title
            Image(systemName: "shield.lefthalf.filled.trianglebadge.exclamationmark")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Project Phoenix")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Sign in to track your health")
                .foregroundColor(.secondary)

            // Text fields for email and password
            VStack(spacing: 15) {
                TextField("Email Address", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            // Display an error message if login fails
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            // Login Button or Progress Indicator
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
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Button("Don't have an account? Sign Up") {
                // Action for signing up would go here
            }
            .font(.footnote)
            
            Spacer()
        }
        .padding()
    }

    /// Handles the login logic.
    func handleLogin() {
        isLoading = true
        errorMessage = ""

        // Basic validation to ensure fields are not empty.
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in both email and password."
            isLoading = false
            return
        }
        
        // Simulate a network request for authentication.
        // In a real app, you would make an API call to your server here.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // For this example, we'll assume the login is always successful.
            // If it failed, you would set `self.errorMessage`.
            isLoading = false
            self.isLoggedIn = true // This triggers the dismissal of the login screen.
        }
    }
}

#Preview {
    ContentView()
}