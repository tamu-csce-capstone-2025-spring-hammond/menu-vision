//
//  MenuVisionUIApp.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 2/26/25.
//

import SwiftUI

@main
struct MenuVisionUIApp: App {
    @StateObject private var restaurantData = RestaurantData()
    @StateObject private var dishMapping = DishMapping()
    @StateObject private var userStateViewModel = UserStateViewModel()
    @StateObject private var userData = UserData()

    init() {
        // Connect userData to the viewModel
        userStateViewModel.setUserData(userData)
    }

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
