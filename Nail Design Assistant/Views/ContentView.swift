import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isSignedIn {
            MainView()
        } else {
            AuthView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
