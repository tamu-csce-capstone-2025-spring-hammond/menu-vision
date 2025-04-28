//
//  RestaurantData.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 3/27/25.
//

import Foundation

/// A class for managing restaurant information in the app.
///
/// This simple observable class stores the current restaurant's ID,
/// which is used throughout the app to fetch restaurant-specific data
/// such as menu items and AR models.
class RestaurantData: ObservableObject {
    /// The unique identifier for the currently selected restaurant.
    ///
    /// This ID is typically a place ID from a mapping service like Google Maps.
    @Published var restaurant_id: String = ""
}
