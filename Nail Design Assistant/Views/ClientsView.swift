import SwiftUI
import Foundation

struct Client: Identifiable {
    let id = UUID()
    let name: String
    let phone: String
    let pastDesignImages: [String]  // array of image asset names
    let appointments: [Appointment]
}


struct ClientsView: View {
    let clients: [Client] = [
        Client(
            name: "Sarah M.",
            phone: "555-123-4567",
            pastDesignImages: ["evilEyes"],
            appointments: [
                Appointment(clientName: "Sarah M.", service: "GelX", date: Date())
            ]
        ),
        Client(
            name: "Michaela T.",
            phone: "555-987-6543",
            pastDesignImages: ["yellowFrench"],
            appointments: [
                Appointment(clientName: "Lina R.", service: "PolyGel", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
            ]
        ),
    ]
    
    var body: some View {
            NavigationView {
                List(clients) { client in
                    NavigationLink(destination: ClientDetailView(client: client)) {
                        VStack(alignment: .leading) {
                            Text(client.name)
                                .font(.headline)
                            Text(client.phone)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .navigationTitle("Clients")
            }
        }
}


