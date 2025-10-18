import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false

    var body: some View {
        VStack(spacing: 25) {
            Text("Log In to FireShield")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                isLoggedIn = true
            }) {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)

            Spacer()

            NavigationLink(destination: DashboardView(username: email.components(separatedBy: "@").first ?? "User"),
                           isActive: $isLoggedIn) {
                EmptyView()
            }
        }
        .padding()
        .navigationTitle("Log In")
    }
}

#Preview {
    LoginView()
}
