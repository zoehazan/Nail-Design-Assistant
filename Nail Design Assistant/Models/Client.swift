import Foundation

struct Client: Identifiable, Codable {
    var id = UUID().uuidString
    var ownerUid: String
    var name: String
    var phone: String?
    var notes: String?
    var createdAt = Date()
}

