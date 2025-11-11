import Foundation

struct Design: Identifiable, Codable {
    var id = UUID().uuidString
    var ownerUid: String
    var clientId: String?
    var prompt: String
    var imageURL: String
    var createdAt = Date()
}
