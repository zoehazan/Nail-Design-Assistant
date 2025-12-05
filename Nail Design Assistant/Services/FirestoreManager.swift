import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreManager {
    static let shared = FirestoreManager()
    private init() {}
    
    let db = Firestore.firestore()
    
    var uid: String { Auth.auth().currentUser?.uid ?? "dev-user" }
    
    // MARK: - Collections
    private var usersCol: CollectionReference { db.collection("users") }
    private var rootDoc: DocumentReference { usersCol.document(uid) }
    private var clientsCol: CollectionReference { rootDoc.collection("clients") }
    private var apptsCol: CollectionReference { rootDoc.collection("appointments") }
    private var designsCol: CollectionReference { rootDoc.collection("designs") }
    
    // MARK: - Client CRUD
    func addClient(_ client: Client) async throws {
        let data: [String: Any] = [
            "id": client.id.uuidString,
            "name": client.name,
            "phone": client.phone as Any,
            "designImageNames": client.designImageNames
        ]
        try await clientsCol.document(client.id.uuidString).setData(data, merge: true)
    }
    
    func listenClients(onChange: @escaping ([Client]) -> Void) -> ListenerRegistration {
        clientsCol.addSnapshotListener { snap, _ in
            let clients: [Client] = snap?.documents.compactMap { doc in
                let d = doc.data()
                guard
                    let idStr = d["id"] as? String,
                    let id = UUID(uuidString: idStr),
                    let name = d["name"] as? String
                else { return nil }
                let phone = d["phone"] as? String
                let designImageNames = d["designImageNames"] as? [String] ?? []
                return Client(id: id, name: name, phone: phone, designImageNames: designImageNames, appointments: [])
            } ?? []
            onChange(clients)
        }
    }
    
    // MARK: - Appointments
    func addAppointment(_ appt: Appointment) async throws {
        let doc = apptsCol.document(appt.id.uuidString)
        let data: [String: Any] = [
            "id": appt.id.uuidString,
            "clientId": appt.clientId?.uuidString as Any,
            "clientName": appt.clientName,
            "service": appt.service,
            "date": Timestamp(date: appt.date),
            "createdAt": FieldValue.serverTimestamp()
        ]
        try await doc.setData(data, merge: true)
    }
    
    // MARK: - Client Updates
    func updateClient(_ client: Client) async throws {
        let data: [String: Any] = [
            "id": client.id.uuidString,
            "name": client.name,
            "phone": client.phone as Any,
            "designImageNames": client.designImageNames
        ]
        try await clientsCol.document(client.id.uuidString).setData(data, merge: true)
    }

    // MARK: - Appointment Updates
    func updateAppointment(_ appt: Appointment) async throws {
        let data: [String: Any] = [
            "id": appt.id.uuidString,
            "clientId": appt.clientId?.uuidString as Any,
            "clientName": appt.clientName,
            "service": appt.service,
            "date": Timestamp(date: appt.date)
        ]
        try await apptsCol.document(appt.id.uuidString).setData(data, merge: true)
    }

    func deleteAppointment(_ appt: Appointment) async throws {
        try await apptsCol.document(appt.id.uuidString).delete()
    }

    
    @discardableResult
    func listenAppointments(onChange: @escaping ([Appointment]) -> Void) -> ListenerRegistration {
        apptsCol.addSnapshotListener { snap, _ in
            let appts: [Appointment] = snap?.documents.compactMap { doc in
                let d = doc.data()
                guard
                    let idStr = d["id"] as? String,
                    let id = UUID(uuidString: idStr),
                    let clientName = d["clientName"] as? String,
                    let service = d["service"] as? String,
                    let ts = d["date"] as? Timestamp
                else { return nil }
                let clientId = (d["clientId"] as? String).flatMap(UUID.init(uuidString:))
                return Appointment(id: id, clientId: clientId, clientName: clientName, service: service, date: ts.dateValue())
            } ?? []
            onChange(appts)
        }
    }
    
    // MARK: - Designs
    func addDesign(ownerUid: String, clientId: String?, prompt: String, imageURL: String) async throws {
        let doc = designsCol.document()
        let data: [String: Any] = [
            "id": doc.documentID,
            "ownerUid": ownerUid,
            "clientId": clientId as Any,
            "prompt": prompt,
            "imageURL": imageURL,
            "createdAt": FieldValue.serverTimestamp()
        ]
        try await doc.setData(data)
    }
    
    func appendDesignString(_ value: String, to client: Client) async throws {
        try await clientsCol
            .document(client.id.uuidString)
            .updateData([
                "designImageNames": FieldValue.arrayUnion([value])
            ])
    }
}

extension FirestoreManager {
    @discardableResult
    func listenAppointments(forClientId clientId: UUID,
                            onChange: @escaping ([Appointment]) -> Void) -> ListenerRegistration {
        apptsCol
            .whereField("clientId", isEqualTo: clientId.uuidString)
            .addSnapshotListener { snap, _ in
                let appts: [Appointment] = snap?.documents.compactMap { doc in
                    let d = doc.data()
                    guard
                        let idStr = d["id"] as? String,
                        let id = UUID(uuidString: idStr),
                        let clientName = d["clientName"] as? String,
                        let service = d["service"] as? String,
                        let ts = d["date"] as? Timestamp
                    else { return nil }
                    let clientId = (d["clientId"] as? String).flatMap(UUID.init(uuidString:))
                    return Appointment(id: id, clientId: clientId, clientName: clientName, service: service, date: ts.dateValue())
                } ?? []
                onChange(appts.sorted(by: { $0.date < $1.date }))
            }
    }
}
