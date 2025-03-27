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
}


struct MenuItemSize: Codable {
    let price: Double?
    let size: String?
}
