import SwiftUI
import FirebaseFirestore
import UIKit

struct ClientDetailView: View {
    // Make client mutable inside this view
    @State private var client: Client
    
    @State private var appts: [Appointment] = []
    @State private var listener: ListenerRegistration?
    
    @State private var showingEditClient = false
    @State private var editingAppointment: Appointment?
    
    init(client: Client) {
        _client = State(initialValue: client)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // HEADER
            Text(client.name)
                .font(.largeTitle)
                .bold()

            Text("Phone: \(client.phone ?? "-")")
                .font(.title3)
                .foregroundColor(.secondary)

            // PAST DESIGNS
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

            // APPOINTMENTS
            Text("Appointments")
                .font(.title2)
                .bold()

            if appts.isEmpty {
                Text("No appointments yet.")
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(appts.sorted(by: { $0.date < $1.date })) { appt in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(appt.service).font(.headline)
                            Text(appt.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingAppointment = appt   // tap to edit
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task {
                                    try? await FirestoreManager.shared.deleteAppointment(appt)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .frame(height: 220)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Client Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditClient = true
                }
            }
        }
        .onAppear {
            // Listen for appointments for THIS client
            listener = FirestoreManager.shared.listenAppointments { all in
                self.appts = all.filter { $0.clientId == client.id }
            }
        }
        .onDisappear {
            listener?.remove(); listener = nil
        }
        // Edit CLIENT sheet
        .sheet(isPresented: $showingEditClient) {
            EditClientView(client: $client) { updated in
                Task {
                    try? await FirestoreManager.shared.updateClient(updated)
                }
            }
        }
        // Edit APPOINTMENT sheet
        .sheet(item: $editingAppointment) { appt in
            EditAppointmentView(appointment: appt) { updated in
                Task {
                    try? await FirestoreManager.shared.updateAppointment(updated)
                }
            }
        }
    }
}
