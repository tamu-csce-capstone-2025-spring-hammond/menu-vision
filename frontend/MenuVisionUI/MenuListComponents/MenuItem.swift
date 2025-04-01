//
//  MenuItem.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 3/27/25.
//

import Foundation

struct MenuResponse: Codable {
    let menu: [String: [MenuItem]]

    var sections: [MenuSection] {
        menu.map { MenuSection(name: $0.key, items: $0.value) }
    }
}

struct MenuSection: Identifiable {
    let id = UUID()
    let name: String
    let items: [MenuItem]
}

struct MenuItem: Codable, Identifiable {
    var id: UUID { UUID() }
    let name: String
    let description: String?
    let sizes: [MenuItemSize]
    let availability: String?
    let spiciness: String?
    let allergens: [String]?
    let dietary_info: [String]?
    let calories: String?
    let popularity: String?
    let addons: [Addon]?
}

struct MenuItemSize: Codable {
    let price: Double?
    let size: String?
}

struct Addon: Codable, Hashable {
    let name: String
    let price: Double?
}
