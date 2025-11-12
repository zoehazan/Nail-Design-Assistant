import SwiftUI
import FirebaseFirestore

struct ClientDetailView: View {
    let client: Client
    
    @State private var appts: [Appointment] = []
    @State private var listener: ListenerRegistration?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(client.name)
                .font(.largeTitle)
                .bold()

            Text("Phone: \(client.phone ?? "-")")
                .font(.title3)
                .foregroundColor(.secondary)

            Text("Past Designs")
                .font(.title2)
                .bold()
            let images = client.designImageNames

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(images, id: \.self) { name in
                        Image(name)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }

            Text("Appointments")
                .font(.title2)
                .bold()
            if appts.isEmpty {
                            Text("No appointments yet.").foregroundColor(.secondary)
            } else {
                List(appts.sorted(by: { $0.date < $1.date })) { appt in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(appt.service).font(.headline)
                        Text(appt.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.secondary) // e.g., “Nov 11, 3:45 PM”
                    }
                }
                .frame(height: 220)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Client Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            listener = FirestoreManager.shared.listenAppointments { all in
                self.appts = all.filter { $0.clientId == client.id }
            }
        }
        .onDisappear {
            listener?.remove(); listener = nil
        }
    }
}

