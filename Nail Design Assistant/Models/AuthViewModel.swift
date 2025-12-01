import Foundation
import FirebaseAuth

final class AuthViewModel: ObservableObject {
    @Published var user: User?
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        // Listen for auth changes
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
            }
        }
    }

    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    var isSignedIn: Bool {
        user != nil
    }
    
    var email: String {
        user?.email ?? "Unknown"
    }


    // MARK: - Email/Password

    @MainActor
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    @MainActor
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    @MainActor
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
