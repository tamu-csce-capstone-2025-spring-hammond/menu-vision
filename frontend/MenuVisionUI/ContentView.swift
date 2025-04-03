import SwiftUI

struct ContentView: View {

    @State private var isLoggedIn = true
    @EnvironmentObject var restaurantData: RestaurantData

    var body: some View {
        Group {
            if isLoggedIn {
                // When logged in, show HomeView
                HomeView()
                    .environmentObject(restaurantData)
                    .transition(.opacity)
                    .animation(.default, value: isLoggedIn)
            } else {
                // When not logged in, show SignUpAndInView with binding to isLoggedIn
                SignUpAndInView(isLoggedIn: $isLoggedIn)
                    .transition(.opacity)
                    .animation(.default, value: isLoggedIn)
            }
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

