import SwiftUI

struct ContentView: View {
  
    @AppStorage("is_logged_in") private var persistentLogin: Bool = false
    @EnvironmentObject var vm: UserStateViewModel
    @State private var isLoggedIn: Bool = false

    var body: some View {
        Group {
            if vm.isLoggedIn {
                // When logged in, show HomeView
                HomeView()
                    .transition(.opacity)
                    .animation(.default, value: vm.isLoggedIn)
            } else {
                // When not logged in, show SignUpAndInView with binding to isLoggedIn
                SignUpAndInView()
                    .transition(.opacity)
                    .animation(.default, value: vm.isLoggedIn)
            }
        }
        // Check persistent login on app launch
        .onAppear {
            if persistentLogin == true {
                vm.isLoggedIn = persistentLogin
            }
            
        }
        // Print statement for debugging
        .onChange(of: vm.isLoggedIn) { newValue in
            print("isLoggedIn changed to: \(newValue)")
        }
    }
}

#Preview {
    ContentView()
}
