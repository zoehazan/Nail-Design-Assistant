import SwiftUI
import Foundation
import FirebaseFirestore 

struct ClientsView: View {
    @State private var clients: [Client] = []
    @State private var listener: ListenerRegistration?
    @State private var showingAdd = false
    
    var body: some View {
        NavigationView {
            Group {
                if clients.isEmpty {
                    ContentUnavailableView("No clients yet",
                                           systemImage: "person.3",
                                           description: Text("Tap + to add your first client."))
                } else {
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
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Clients")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Client")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddClientView { newClient in
                Task {
                    do {
                        try await FirestoreManager.shared.addClient(newClient)
                    } catch {
                        print("⚠️ Failed to save client: \(error.localizedDescription)")
                    }
                }
            }
        }
        .onAppear {
            // Start listening to Firestore
            listener = FirestoreManager.shared.listenClients { fetched in
                self.clients = fetched.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
            }
        }
        .onDisappear {
            // Stop listening
            listener?.remove()
            listener = nil
        }
    }
}

struct AddClientView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var phone = ""

    // Parent provides what to do with the new Client
    let onSave: (Client) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Phone (optional)", text: $phone)
                    .keyboardType(.phonePad)
            }
            .navigationTitle("New Client")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let client = Client(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : phone,
                            designImageNames: [],
                            appointments: []
                        )
                        onSave(client)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct EditClientView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var client: Client
    let onSave: (Client) -> Void
    
    @State private var name: String = ""
    @State private var phone: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Phone (optional)", text: $phone)
                    .keyboardType(.phonePad)
            }
            .navigationTitle("Edit Client")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = client
                        updated.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
                        updated.phone = trimmedPhone.isEmpty ? nil : trimmedPhone
                        
                        client = updated          // update local state
                        onSave(updated)           // propagate to Firestore
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            // Seed fields from current client
            name = client.name
            phone = client.phone ?? ""
        }
    }
}


