import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section("Account") {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(authViewModel.email)
                            .foregroundColor(.secondary)
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        signOut()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func signOut() {
        do {
            try authViewModel.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
