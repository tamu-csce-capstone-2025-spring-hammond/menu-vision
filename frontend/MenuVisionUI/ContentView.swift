import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = true // changed for testing

    var body: some View {
        Group {
            if isLoggedIn {
                HomeView()
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}

#Preview {
    ContentView()
}
