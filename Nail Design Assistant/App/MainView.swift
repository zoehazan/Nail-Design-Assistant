import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            ClientsView()
                .tabItem {
                    Label("Clients", systemImage: "person.3.fill")
                }
            
            AIHelperView()
                .tabItem {
                    Label("AI Helper", systemImage: "sparkles")
                }
        }
        .accentColor(.pink) // This sets the selected tab color
    }
}

