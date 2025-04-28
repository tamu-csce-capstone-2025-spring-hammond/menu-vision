import SwiftUI
/// A view that manages the app's root navigation based on user authentication state.
///
/// The `ContentView` serves as the primary entry point for the application's user interface,
/// dynamically switching between authentication and main app views based on the user's login status.
///
/// - Note: This view relies on `UserStateViewModel` to manage authentication state.
///
/// ## Topics
/// ### State Management
/// - Persistent login tracking via `@AppStorage`
/// - Dynamic view rendering based on login status
///
/// ## Example
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         // Automatically switches between login and home views
///     }
/// }
/// ```
///
/// - SeeAlso: `UserStateViewModel`, `HomeView`, `SignUpAndInView`
struct ContentView: View {
    /// Persists login state across app launches using `@AppStorage`.
    ///
    /// - Default value is `false`, indicating user is not logged in.
    /// - Automatically saved and retrieved from device storage.
    @AppStorage("is_logged_in")
    private var persistentLogin: Bool = false
    
    /// Provides access to the shared user state view model.
    ///
    /// - Important: This must be injected from the environment to manage login state.
    @EnvironmentObject
    var vm: UserStateViewModel
    
    /// Tracks the current login state within the view.
    ///
    /// - Note: This is a local state that can be used for additional view-specific logic.
    @State
    private var isLoggedIn: Bool = false

    /// Renders the appropriate view based on the user's authentication status.
    ///
    /// - Returns: Either `HomeView` or `SignUpAndInView` depending on login state.
    /// - Note: Applies opacity transition and default animation for smooth state changes.
    var body: some View {
        Group {
            if vm.isLoggedIn {
                // Displays the main app interface when user is logged in
                HomeView()
                    .transition(.opacity)
                    .animation(.default, value: vm.isLoggedIn)
            } else {
                // Shows authentication interface when user is not logged in
                SignUpAndInView()
                    .transition(.opacity)
                    .animation(.default, value: vm.isLoggedIn)
            }
        }
        // Checks and restores persistent login on app launch
        .onAppear {
            if persistentLogin == true {
                vm.isLoggedIn = persistentLogin
            }
        }
        // Logs login state changes for debugging purposes
        .onChange(of: vm.isLoggedIn) { newValue in
            print("isLoggedIn changed to: \(newValue)")
        }
    }
}

/// Provides a preview of the `ContentView` for development and design purposes.
///
/// - Note: This preview is used in Xcode's preview canvas to visualize the view during development.
#Preview {
    ContentView()
}
