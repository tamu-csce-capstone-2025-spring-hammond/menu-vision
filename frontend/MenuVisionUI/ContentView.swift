import SwiftUI

struct ContentView: View {
  
    @AppStorage("is_logged_in") private var persistentLogin: Bool = false
    @State private var isLoggedIn: Bool = false

    var body: some View {
        Group {
            if isLoggedIn {
                // When logged in, show HomeView
                HomeView()
                    .transition(.opacity)
                    .animation(.default, value: isLoggedIn)
            } else {
                // When not logged in, show SignUpAndInView with binding to isLoggedIn
                SignUpAndInView(isLoggedIn: $isLoggedIn)
                    .transition(.opacity)
                    .animation(.default, value: isLoggedIn)
            }
        }
        // Check persistent login on app launch
        .onAppear {
            isLoggedIn = persistentLogin
        }
        // Print statement for debugging
        .onChange(of: isLoggedIn) { newValue in
            print("isLoggedIn changed to: \(newValue)")
        }
    }
}

#Preview {
    ContentView()
}
