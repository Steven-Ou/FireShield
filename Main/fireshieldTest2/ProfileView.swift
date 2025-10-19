import SwiftUI

struct ProfileView: View {
    let username: String
    
    var body: some View {
        ZStack {
            // Changed background to white for consistency
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable().frame(width: 100, height: 100)
                    .foregroundColor(.gray) // Changed icon color
                    .padding(.top, 40)
                
                Text(username).font(.title2).fontWeight(.bold).foregroundColor(.black)
                
                VStack(spacing: 15) {
                    Button("Edit Profile") { }
                        .foregroundColor(.black)
                    Divider()
                    Button("App Settings") { }
                        .foregroundColor(.black)
                    Divider()
                    Button("Log Out") { /* hook into AppState.logout() where presented */ }
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .padding()
                
                Spacer()
            }
        }
        .navigationTitle("Profile")
    }
}


#Preview { ProfileView(username: "Alex") }

