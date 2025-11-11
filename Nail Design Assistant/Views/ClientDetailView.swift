import SwiftUI

struct ClientDetailView: View {
    let client: Client

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(client.name)
                .font(.largeTitle)
                .bold()

            Text("Phone: \(client.phone)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Past Designs")
                .font(.title2)
                .bold()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(client.pastDesignImages, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 5)
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
            .frame(height: 200) // fix list height inside VStack

            Spacer()
        }
        .padding()
        .navigationTitle("Client Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

