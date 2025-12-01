import SwiftUI
import FirebaseFirestore
import UIKit

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

            if images.isEmpty {
                Text("No saved designs yet.")
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(images, id: \.self) { base64 in
                            if let data = Data(base64Encoded: base64),
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }

            Text("Appointments")
                .font(.title2)
                .bold()

            if appts.isEmpty {
                Text("No appointments yet.")
                    .foregroundColor(.secondary)
            } else {
                List(appts.sorted(by: { $0.date < $1.date })) { appt in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(appt.service).font(.headline)
                        Text(appt.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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
