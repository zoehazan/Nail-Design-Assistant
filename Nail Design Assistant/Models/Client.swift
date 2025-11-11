import Foundation

struct Client: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var phone: String?
    var designImageNames: [String]
    var appointments: [Appointment]
    
    init(id: UUID = UUID(), name: String, phone: String? = nil, designImageNames: [String] = [], appointments: [Appointment] = []) {
            self.id = id
            self.name = name
            self.phone = phone
            self.designImageNames = designImageNames
            self.appointments = appointments
    }
}

