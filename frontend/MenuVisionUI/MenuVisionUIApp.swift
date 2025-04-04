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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(restaurantData)
                .environmentObject(dishMapping)
        }
    }
}
