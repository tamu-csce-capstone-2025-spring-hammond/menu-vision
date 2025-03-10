import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = true

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
