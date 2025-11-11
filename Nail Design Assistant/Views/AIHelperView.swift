import SwiftUI

struct AIHelperView: View {
    @State private var userInput: String = ""
    @State private var messages: [String] = ["Welcome to your creative assistant!"]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages, id: \.self) { msg in
                        Text(msg)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Divider()
            
            HStack {
                TextField("Type your prompt...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Send") {
                    sendMessage()
                }
                .bold()
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 0) // This tells SwiftUI to respect the bottom safe area
        }
    }
    
    func sendMessage() {
        guard !userInput.isEmpty else { return }
        messages.append(userInput)
        userInput = ""
    }
}
