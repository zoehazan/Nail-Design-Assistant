import SwiftUI
import FirebaseFirestore 

struct CalendarView: View {
    @State private var appointments: [Appointment] = []
    @State private var clients: [Client] = []
    
    @State private var selectedDate = Date()
    @State private var showingAddSheet = false
    
    @State private var apptListener: ListenerRegistration?
    @State private var clientListener: ListenerRegistration?


    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Text("Appointments on \(formatted(selectedDate))")
                    .font(.headline)
                    .padding(.horizontal)
                
                List(filteredAppointments(for: selectedDate)) { appointment in
                    VStack(alignment: .leading) {
                        Text(appointment.clientName)
                            .font(.headline)
                        Text("\(appointment.service) at \(timeFormatted(appointment.date))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .listStyle(.plain)
                
                Spacer(minLength: 60) // Space for nav bar
            }
            
            Button {
                showingAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 28))
                    .padding()
                    .background(Color.pink)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    .padding(.trailing)
            }
            .padding(.bottom, 70) // above the nav bar
        }
        .sheet(isPresented: $showingAddSheet) {
            AddAppointmentView(clients: clients) { appt in
                Task { try? await FirestoreManager.shared.addAppointment(appt) }
            }
        }
        .onAppear {
            // Global list of appointments (for the calendar)
            apptListener = FirestoreManager.shared.listenAppointments { appts in
                self.appointments = appts.sorted(by: { $0.date < $1.date })
            }
            // Live list of clients (for the picker)
            clientListener = FirestoreManager.shared.listenClients { self.clients = $0 }
        }
        .onDisappear {
            apptListener?.remove(); apptListener = nil
            clientListener?.remove(); clientListener = nil
        }
    }
    
    private func filteredAppointments(for date: Date) -> [Appointment] {
        appointments.filter { startOfDay(for: $0.date) == startOfDay(for: date) }
    }

    private func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func timeFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AddAppointmentView: View {
    @Environment(\.dismiss) private var dismiss
    let clients: [Client]
    let onSave: (Appointment) -> Void

    @State private var selectedClientIndex: Int = 0
    @State private var service = ""
    @State private var date = Date()

    var body: some View {
        NavigationView {
            Form {
                if clients.isEmpty {
                    Text("Add a client first in the Clients tab.").foregroundColor(.secondary)
                } else {
                    Picker("Client", selection: $selectedClientIndex) {
                        ForEach(clients.indices, id: \.self) { i in
                            Text(clients[i].name).tag(i)
                        }
                    }
                }
                TextField("Service (e.g., GelX, Fill…)", text: $service)
                DatePicker("Date & Time", selection: $date)
            }
            .navigationTitle("New Appointment")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard clients.indices.contains(selectedClientIndex) else { return }
                        let c = clients[selectedClientIndex]
                        let appt = Appointment(clientId: c.id,
                                               clientName: c.name,
                                               service: service,
                                               date: date)
                        onSave(appt)
                        dismiss()
                    }
                    .disabled(clients.isEmpty || service.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}
