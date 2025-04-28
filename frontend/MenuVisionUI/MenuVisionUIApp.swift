import SwiftUI

/// The main application entry point for MenuVision, managing global state and environment objects.
///
/// This app struct initializes key view models and sets up the application's initial state,
/// including user authentication and data management.
@main
struct MenuVisionUIApp: App {
    /// Manages restaurant-specific data across the application.
    ///
    /// Provides a shared data source for restaurant information that can be accessed
    /// by multiple views through the environment.
    @StateObject private var restaurantData = RestaurantData()
    
    /// Handles mapping and management of dish-related data and AR models.
    ///
    /// Tracks dish information, model availability, and loading states for AR functionality.
    @StateObject private var dishMapping = DishMapping()
    
    /// Manages the overall user authentication and state management.
    ///
    /// Handles login status, user data retrieval, and state transitions.
    @StateObject private var userStateViewModel = UserStateViewModel()
    
    /// Stores and manages detailed user information.
    ///
    /// Provides a comprehensive object for storing and updating user-specific data.
    @StateObject private var userData = UserData()
    
    /// Initializes the application and connects user data to the view model.
    ///
    /// Sets up the initial connection between `userData` and `userStateViewModel`
    /// to ensure synchronized user information management.
    init() {
        // Connect userData to the viewModel
        userStateViewModel.setUserData(userData)
    }
    
    /// Defines the main scene and structure of the application.
    ///
    /// Configures the root navigation, environment objects, and initial app behavior:
    /// - Sets up a NavigationStack with ContentView
    /// - Injects environment objects for global state management
    /// - Handles initial login state checking
    /// - Manages login state change reactions
    ///
    /// - Returns: A configured WindowGroup with the app's initial view hierarchy
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environmentObject(restaurantData)
            .environmentObject(dishMapping)
            .environmentObject(userStateViewModel)
            .environmentObject(userData)
            .onAppear {
                // Check for previously logged in state and load data if needed
                if UserDefaults.standard.bool(forKey: "is_logged_in") {
                    userStateViewModel.isLoggedIn = true
                }
            }
            .onChange(of: userStateViewModel.isLoggedIn) { newValue in
                // React to login state changes
                userStateViewModel.didChangeLoginState()
            }
        }
    }
}
