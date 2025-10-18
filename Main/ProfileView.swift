import SwiftUI

struct ProfileView: View {
    let username: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
                .padding(.top, 40)

            Text(username)
                .font(.title2)
                .fontWeight(.bold)

            Divider()

            VStack(spacing: 15) {
                Button("Edit Profile") { }
                Button("App Settings") { }
                Button("Log Out") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding()

            Spacer()
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    ProfileView(username: "Alex")
}
