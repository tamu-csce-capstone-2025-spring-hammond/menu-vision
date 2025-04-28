//
//  MenuItem.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 3/27/25.
//

import Foundation

/// Response structure that wraps menu sections with menu items
struct MenuResponse: Codable {
    /// Dictionary mapping section names to arrays of menu items
    let menu: [String: [MenuItem]]

    /// Computed property that converts the dictionary into an array of MenuSection objects
    var sections: [MenuSection] {
        menu.map { MenuSection(name: $0.key, items: $0.value) }
    }
}

/// Represents a section in a menu containing a name and a collection of menu items
struct MenuSection: Identifiable {
    /// Unique identifier for the section
    let id = UUID()
    /// Display name of the section
    let name: String
    /// Collection of menu items in this section
    let items: [MenuItem]
}

/// Represents a dish or item on a menu with various attributes like name, description, pricing, etc.
struct MenuItem: Codable, Identifiable {
    /// Unique identifier for the menu item
    var id: UUID { UUID() }
    /// Name of the dish
    let name: String
    /// Optional description of the dish
    let description: String?
    /// Available sizes and their corresponding prices
    let sizes: [MenuItemSize]
    /// Information about when the item is available, if specified
    let availability: String?
    /// Indication of how spicy the dish is, if applicable
    let spiciness: String?
    /// List of allergens present in the dish
    let allergens: [String]?
    /// List of dietary information or tags (e.g., vegetarian, gluten-free)
    let dietary_info: [String]?
    /// Caloric content of the dish, if available
    let calories: String?
    /// Popularity ranking or special designation (e.g., "Bestseller")
    let popularity: String?
    /// Optional add-ons or customizations available for this dish
    let addons: [Addon]?

    /// Optional mapping to corresponding dish data from a model, allowing for enhanced information
    var matchedDishData: [DishData]? = nil

    /// Coding keys for JSON serialization/deserialization
    enum CodingKeys: String, CodingKey {
        case name, description, sizes, availability, spiciness, allergens, dietary_info, calories, popularity, addons
    }
}

/// Represents a size option for a menu item, typically with a size name and price
struct MenuItemSize: Codable {
    /// The price for this size option
    let price: Double?
    /// The name of the size option (e.g., "Small", "Medium", "Large")
    let size: String?
}

/// Represents an optional add-on or customization for a menu item
struct Addon: Codable, Hashable {
    /// Name of the add-on
    let name: String
    /// Optional price for the add-on
    let price: Double?
}
