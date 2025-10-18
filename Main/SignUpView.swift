import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignedUp = false

    var body: some View {
        VStack(spacing: 25) {
            Text("Create a FireShield Account")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                isSignedUp = true
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()

            NavigationLink(destination: DashboardView(username: email.components(separatedBy: "@").first ?? "User"),
                           isActive: $isSignedUp) {
                EmptyView()
            }
        }
        .padding()
        .navigationTitle("Sign Up")
    }
}

#Preview {
    SignupView()
}
