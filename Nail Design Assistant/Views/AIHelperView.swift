import SwiftUI
import UIKit
import FirebaseFirestore

struct AIHelperView: View {
    @State private var promptText: String = ""
    @State private var lastPrompt: String = ""
    @State private var isLoading: Bool = false
    @State private var generatedImage: UIImage?
    @State private var errorMessage: String?

    // Clients for attaching designs
    @State private var clients: [Client] = []
    @State private var clientListener: ListenerRegistration?

    // Attach state (no sheet now)
    @State private var selectedClientIndex: Int = 0
    @State private var isSavingDesign: Bool = false
    @State private var saveError: String?
    @State private var saveSuccessMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .center, spacing: 16) {

                    if let image = generatedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 8)

                        // Attach UI inline instead of a sheet
                        if clients.isEmpty {
                            Text("Design generated! Add a client in the Clients tab to attach it.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        } else {
                            VStack(alignment: .center, spacing: 8) {
                                Text("Attach this design to a client:")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                                
                                Picker("", selection: $selectedClientIndex) {
                                    ForEach(clients.indices, id: \.self) { i in
                                        Text(clients[i].name).tag(i)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .frame(maxWidth: .infinity)          // center the dropdown
                                .multilineTextAlignment(.center)
                                
                                Button {
                                    Task { await saveDesignForSelectedClient() }
                                } label: {
                                    HStack {
                                        if isSavingDesign {
                                            ProgressView()
                                        }
                                        Text("Save to Client")
                                            .bold()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.pink)
                                .disabled(isSavingDesign || !clients.indices.contains(selectedClientIndex))
                                
                                if let saveError {
                                    Text(saveError)
                                        .foregroundColor(.red)
                                        .font(.footnote)
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                }
                                
                                if let saveSuccessMessage {
                                    Text(saveSuccessMessage)
                                        .foregroundColor(.green)
                                        .font(.footnote)
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.top, 8)
                            .frame(maxWidth: 300)
                        }

                    } else {
                        Text("Type a nail design prompt below and tap **Generate** to see an AI-created design ✨")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                    }

                    if isLoading {
                        ProgressView("Generating design…")
                            .padding(.top, 8)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                TextField("soft pink almond nails with tiny white hearts…",
                          text: $promptText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)

                Button(action: generateTapped) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Generate")
                            .bold()
                    }
                }
                .disabled(promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .navigationTitle("AI Design Helper")
        .onAppear {
            clientListener = FirestoreManager.shared.listenClients { fetched in
                self.clients = fetched.sorted {
                    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
                // reset selection if needed
                if !clients.isEmpty && !clients.indices.contains(selectedClientIndex) {
                    selectedClientIndex = 0
                }
            }
        }
        .onDisappear {
            clientListener?.remove()
            clientListener = nil
        }
    }

    // MARK: - Generate

    private func generateTapped() {
        let trimmed = promptText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        lastPrompt = trimmed
        errorMessage = nil
        saveError = nil
        saveSuccessMessage = nil
        isLoading = true

        Task {
            do {
                let image = try await AIService.shared.generateDesign(prompt: trimmed)
                generatedImage = image
                isLoading = false

                if clients.isEmpty {
                    errorMessage = "Design generated! Add a client first in the Clients tab to attach it."
                }
            } catch {
                print("❌ AI error:", error)
                errorMessage = "Couldn’t generate design. Check that the backend is running and reachable."
                isLoading = false
            }
        }
    }

    // MARK: - Save to client (still using base64 + Firestore)

    @MainActor
    private func saveDesignForSelectedClient() async {
        guard
            !clients.isEmpty,
            clients.indices.contains(selectedClientIndex),
            let image = generatedImage
        else {
            return
        }

        isSavingDesign = true
        saveError = nil
        saveSuccessMessage = nil

        let client = clients[selectedClientIndex]

        do {
            guard let data = image.jpegData(compressionQuality: 0.7) else {
                throw NSError(domain: "AIHelperView", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Could not encode image."
                ])
            }
            let base64 = data.base64EncodedString()

            let fm = FirestoreManager.shared

            try await fm.addDesign(
                ownerUid: fm.uid,
                clientId: client.id.uuidString,
                prompt: lastPrompt,
                imageURL: base64
            )

            try await fm.appendDesignString(base64, to: client)

            isSavingDesign = false
            saveSuccessMessage = "Design saved to \(client.name)."
        } catch {
            print("❌ Save design error:", error)
            saveError = "Couldn’t save design. Please try again."
            isSavingDesign = false
        }
    }
}
