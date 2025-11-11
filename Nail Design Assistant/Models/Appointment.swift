import Foundation

struct Appointment: Identifiable, Codable {
    var id = UUID().uuidString
    var ownerUid: String
    var clientId: String
    var start: Date
    var end: Date
    var notes: String?
}
