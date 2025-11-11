import SwiftUI

struct Appointment: Identifiable {
    let id = UUID()
    let clientName: String
    let service: String
    let date: Date
}

struct CalendarView: View {
    @State private var appointments: [Appointment] = [
        Appointment(clientName: "Sarah M.", service: "GelX", date: Date()),
        Appointment(clientName: "Michaela T.", service: "PolyGel", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
    ]
    @State private var selectedDate: Date = Date()
    @State private var showingAddSheet = false

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

            Button(action: {
                    showingAddSheet = true
                }) {
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
                AddAppointmentView(appointments: $appointments)
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
    @Environment(\.dismiss) var dismiss
    @Binding var appointments: [Appointment]
    @State private var clientName = ""
    @State private var service = ""
    @State private var date = Date()

    var body: some View {
        NavigationView {
            Form {
                TextField("Client Name", text: $clientName)
                TextField("Service", text: $service)
                DatePicker("Date & Time", selection: $date)
            }
            .navigationTitle("New Appointment")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newAppt = Appointment(clientName: clientName, service: service, date: date)
                        appointments.append(newAppt)
                        dismiss()
                    }
                    .disabled(clientName.isEmpty || service.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

