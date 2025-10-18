import SwiftUI

struct ChatbotView: View {
    @State private var input = ""
    @State private var messages: [Message] = [Message(content: "Hi! I’m your FireShield assistant. How can I help you today?", isUser: false)]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                // Header
                Text("FireShield Assistant")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    .padding(.top)

                // Chat messages
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(messages) { msg in
                            HStack {
                                if msg.isUser {
                                    Spacer()
                                    Text(msg.content)
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(15)
                                        .frame(maxWidth: 280, alignment: .trailing)
                                } else {
                                    Text(msg.content)
                                        .padding()
                                        .foregroundColor(.black)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(15)
                                        .frame(maxWidth: 280, alignment: .leading)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
                .scrollContentBackground(.hidden)

                // Input field
                HStack {
                    TextField("Ask FireShield...", text: $input)
                        .padding(10)
                        .background(.regularMaterial)
                        .cornerRadius(10)
                    
                    Button("Send") {
                        sendMessage()
                    }
                    .padding(.horizontal)
                    .foregroundColor(.white)
                }
                .padding()
            }
        }
    }

    func sendMessage() {
        if !input.isEmpty {
            messages.append(Message(content: input, isUser: true))
            // Here you would add your logic to get a response from a chatbot API
            // For now, we'll just add a simulated response.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                messages.append(Message(content: "Thanks for your question! I'm still in training, but I'm learning more every day.", isUser: false))
            }
            input = ""
        }
    }
}

// A simple struct to hold our message data
struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}


struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        ChatbotView()
    }
}

