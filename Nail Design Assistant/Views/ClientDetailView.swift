import SwiftUI



struct ClientDetailView: View {
    let client: Client

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(client.name)
                .font(.largeTitle)
                .bold()

            Text("Phone: \(client.phone ?? "-")")
                .font(.subheadline)
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

            List(client.appointments) { appointment in
                VStack(alignment: .leading) {
                    Text(appointment.service)
                        .font(.headline)
                    Text(appointment.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 200) 

            Spacer()
        }
        .padding()
        .navigationTitle("Client Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

