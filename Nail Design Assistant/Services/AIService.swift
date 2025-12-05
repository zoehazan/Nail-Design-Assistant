import Foundation
import UIKit

final class AIService {
    static let shared = AIService()
    private init() {}
    
    // Matches your backend JSON: { "image_base64": "...." }
    private struct NailImageResponse: Decodable {
        let image_base64: String
    }
    
    // Body we send: { "prompt": "..." }
    private struct PromptRequest: Encodable {
        let prompt: String
    }
    
    func generateDesign(prompt: String) async throws -> UIImage {
        guard let url = URL(string: "https://nail-ai-backend.onrender.com/generate-nail-image") else {
            throw URLError(.badURL)
        }
        
        // 1️⃣ Clean up the user text
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 2️⃣ Wrap it so the model ALWAYS sees a "nail art" request
        let wrappedPrompt = """
        Highly detailed close-up photo of real human hands with a professional nail art manicure. \
        Focus tightly on the nails only; crop out faces and bodies. \
        Nail design description: \(trimmed). \
        Background soft and unobtrusive, like a salon portfolio photo. \
        This should be a nail design image, not a general illustration.
        """
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 3️⃣ Send the wrapped prompt to your backend
        let body = PromptRequest(prompt: wrappedPrompt)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Basic HTTP status check
        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            let text = String(data: data, encoding: .utf8) ?? ""
            print("❌ Backend HTTP error \(http.statusCode): \(text)")
            throw URLError(.badServerResponse)
        }
        
        // Decode { image_base64: "..." }
        let decoded = try JSONDecoder().decode(NailImageResponse.self, from: data)
        
        guard let imageData = Data(base64Encoded: decoded.image_base64),
              let image = UIImage(data: imageData) else {
            print("❌ Could not turn base64 into UIImage")
            throw NSError(domain: "AIService", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Invalid image data from backend"
            ])
        }
        
        return image
    }
}
