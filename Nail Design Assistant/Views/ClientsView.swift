import SwiftUI
import Foundation

struct ClientsView: View {
    @State var clients: [Client] = []
    
    var body: some View {
            NavigationView {
                List(clients) { client in
                    NavigationLink(destination: ClientDetailView(client: client)) {
                        VStack(alignment: .leading) {
                            Text(client.name)
                                .font(.headline)
                            Text(client.phone ?? "Not provided")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .navigationTitle("Clients")
            }
        }
}


