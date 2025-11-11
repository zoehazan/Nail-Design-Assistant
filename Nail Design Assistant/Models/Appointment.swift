import Foundation

struct Appointment: Identifiable, Codable, Hashable {
    let id: UUID
        var clientId: UUID?        // optional while we’re not wiring real Clients ↔ Appts
        var clientName: String
        var service: String
        var date: Date

        init(id: UUID = UUID(), clientId: UUID? = nil, clientName: String, service: String, date: Date) {
            self.id = id
            self.clientId = clientId
            self.clientName = clientName
            self.service = service
            self.date = date
        }
}
