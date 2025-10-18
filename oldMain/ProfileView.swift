import SwiftUI

struct ProfileView: View {
    let username: String
    @EnvironmentObject var viewRouter: ViewRouter // Get the router to handle logout

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

                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.orange)
                        .shadow(radius: 5)
                        .padding(.top, 40)

                    Text(username)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Divider().padding(.horizontal)

                    VStack(spacing: 15) {
                        Button("Edit Profile") { }
                            .buttonStyle(ProfileButtonStyle())
                        
                        Button("App Settings") { }
                            .buttonStyle(ProfileButtonStyle())
                        
                        Button("Log Out") {
                            // Go back to the onboarding/login flow
                            viewRouter.goToOnboarding()
                        }
                        .buttonStyle(ProfileButtonStyle(isDestructive: true))
                    }
                    .padding()
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding()
                
                Spacer()
            }
        }
    }
}

// A custom button style for the profile page for a consistent look
struct ProfileButtonStyle: ButtonStyle {
    var isDestructive: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isDestructive ? Color.red.opacity(0.8) : Color.blue.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(username: "Alex")
            .environmentObject(ViewRouter())
    }
}

