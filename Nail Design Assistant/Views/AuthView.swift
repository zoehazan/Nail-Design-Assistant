import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoginMode: Bool = true
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                
                Text("Nail Design Assistant")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                
                Spacer()   // <— pushes content into center

                VStack(spacing: 24) {
                    // LOGIN / SIGNUP TITLE (centered)
                    Text(isLoginMode ? "Welcome back" : "Create an account")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    // INPUT FIELDS
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textFieldStyle(.roundedBorder)

                        SecureField("Password (min 6 characters)", text: $password)
                            .textContentType(.password)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    // ERROR MESSAGE
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .padding(.horizontal)
                    }

                    // MAIN BUTTON
                    Button(action: authenticate) {
                        HStack {
                            if isLoading { ProgressView() }
                            Text(isLoginMode ? "Log In" : "Sign Up")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // SWITCH MODE
                    Button {
                        isLoginMode.toggle()
                        errorMessage = nil
                    } label: {
                        Text(
                            isLoginMode
                            ? "Need an account? Sign up"
                            : "Already have an account? Log in"
                        )
                        .font(.footnote)
                    }
                }

                Spacer()   // <— pushes down, completing center alignment
            }
            .padding()
        }
    }

    private func authenticate() {
        errorMessage = nil
        isLoading = true

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            errorMessage = "Please enter both email and password."
            isLoading = false
            return
        }

        Task {
            do {
                if isLoginMode {
                    try await authViewModel.signIn(email: trimmedEmail, password: trimmedPassword)
                } else {
                    try await authViewModel.signUp(email: trimmedEmail, password: trimmedPassword)
                }
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    AuthView().environmentObject(AuthViewModel())
}
