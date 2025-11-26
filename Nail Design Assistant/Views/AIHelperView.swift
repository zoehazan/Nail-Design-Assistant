import SwiftUI
import UIKit

struct AIHelperView: View {
    @State private var promptText: String = ""
    @State private var isLoading: Bool = false
    @State private var generatedImage: UIImage?
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    
                    if let image = generatedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 8)
                    } else {
                        Text("Type a nail design prompt below and tap **Generate** to see an AI-created design ✨")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                    }
                    
                    if isLoading {
                        ProgressView("Generating design…")
                            .padding(.top, 8)
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                }
                .padding()
            }
            
            Divider()
            
            HStack {
                TextField("soft pink almond nails with tiny white hearts…",
                          text: $promptText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)
                
                Button(action: generateTapped) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Generate")
                            .bold()
                    }
                }
                .disabled(promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .navigationTitle("AI Design Helper")
    }
    
    private func generateTapped() {
        let trimmed = promptText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                let image = try await AIService.shared.generateDesign(prompt: trimmed)
                generatedImage = image
            } catch {
                print("❌ AI error:", error)
                errorMessage = "Couldn’t generate design. Check that the backend is running and reachable."
            }
            isLoading = false
        }
    }
}
