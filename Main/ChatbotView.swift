import SwiftUI

struct ChatbotView: View {
    @State private var input = ""
    @State private var messages: [String] = ["Hi! I’m your FireShield assistant. How can I help you today?"]

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages, id: \.self) { msg in
                        Text(msg)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }

            HStack {
                TextField("Ask FireShield...", text: $input)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    if !input.isEmpty {
                        messages.append("You: \(input)")
                        input = ""
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("FireShield Chat")
    }
}

#Preview {
    ChatbotView()
}
