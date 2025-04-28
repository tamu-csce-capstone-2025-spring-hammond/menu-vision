import SwiftUI

/// The main view for the MenuVision application, providing a tabbed interface for navigation.
///
/// This view manages the app's primary navigation using a TabView, allowing users to switch between
/// different sections of the application.
///
/// - Important: The view uses a custom tab bar appearance that adapts to light and dark modes.
struct HomeView: View {
    /// The currently selected tab in the application.
    ///
    /// - Tag values:
    ///   - 0: Model Scan view
    ///   - 1: Home/MenuScanner view
    ///   - 2: Settings/Profile view
    @State private var selection = 1
    
    /// The restaurant data shared across the application.
    ///
    /// This environment object provides access to restaurant-related information
    /// and can be used by child views.
    @EnvironmentObject var restaurantData: RestaurantData
    
    /// The current color scheme of the device.
    ///
    /// Used to adapt the user interface to light or dark mode.
    @Environment(\.colorScheme) var colorScheme
    
    /// Initializes the HomeView with a custom UITabBar appearance.
    ///
    /// Sets the background color of the tab bar based on the current interface style:
    /// - Dark mode: Black with 80% opacity
    /// - Light mode: White with 80% opacity
    ///
    /// - Note: This customization affects the entire app's tab bar appearance.
    init() {
        UITabBar.appearance().backgroundColor = UIColor { mode in
            if mode.userInterfaceStyle == .dark {
                return UIColor.black.withAlphaComponent(0.8)
            } else {
                return UIColor.white.withAlphaComponent(0.8)
            }
        }
    }
    
    /// The body of the HomeView, defining the app's tab structure.
    ///
    /// Provides three main tabs:
    /// 1. Model Scan: For scanning and creating 3D models
    /// 2. Home: The main menu scanning interface
    /// 3. Profile: User settings and profile management
    ///
    /// - Returns: A TabView with custom tab items and navigation
    var body: some View {
        TabView(selection: $selection) {
            // Model Scan Tab
            ScanView()
                .tabItem {
                    Label("Model Scan", systemImage: "camera")
                }
                .tag(0)
            
            // Home/Menu Scanner Tab
            NavigationStack {
                MenuScannerView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(1)
            
            // Profile/Settings Tab
            SettingsView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)
        }
        .accentColor(.orange300)
    }
}
