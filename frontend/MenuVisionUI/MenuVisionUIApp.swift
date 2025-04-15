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

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            
                .environmentObject(restaurantData)
                .environmentObject(dishMapping)
                .environmentObject(userStateViewModel)
        }
    }
}
