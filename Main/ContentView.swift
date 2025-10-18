import SwiftUI

struct ContentView: View {
    // This view owns the data, so we use @State
    @State private var isLoggedIn = false

    // State for the text fields and UI
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "shield.lefthalf.filled.trianglebadge.exclamationmark")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Fire Shield")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Sign in to track your health")
                .foregroundColor(.secondary)

            VStack(spacing: 15) {
                TextField("Email Address", text: $email)
                    // These modifiers are for iOS to style the text field
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

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
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
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Button("Don't have an account? Sign Up") {
                // Action for signing up
            }
            .font(.footnote)
            
            Spacer()
        }
        .padding()
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
