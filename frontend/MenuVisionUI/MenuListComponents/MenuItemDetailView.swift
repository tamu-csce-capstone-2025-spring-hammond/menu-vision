//
//  MenuItemDetailView.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 3/27/25.
//

import SwiftUI

/// A detailed view that displays comprehensive information about a menu item
struct MenuItemDetailView: View {
    /// The menu item to display in detail
    let item: MenuItem

    /// The body of the view that displays the item details in sections
    var body: some View {
        NavigationView {
            List {
                /// Description section
                Section(header: Text("Description")) {
                    Text(item.description ?? "No description available.")
                }

                /// Spiciness section, displayed only if available
                if let spiciness = item.spiciness {
                    Section(header: Text("Spiciness")) {
                        Text(spiciness)
                    }
                }

                /// Calories section, displayed only if available
                if let calories = item.calories {
                    Section(header: Text("Calories")) {
                        Text(calories)
                    }
                }

                /// Popularity section, displayed only if available
                if let popularity = item.popularity {
                    Section(header: Text("Popularity")) {
                        Text(popularity)
                    }
                }

                /// Availability section, displayed only if available
                if let availability = item.availability {
                    Section(header: Text("Availability")) {
                        Text(availability)
                    }
                }

                /// Allergens section, displayed only if allergens are present
                if let allergens = item.allergens, !allergens.isEmpty {
                    Section(header: Text("Allergens")) {
                        ForEach(allergens, id: \.self) { allergen in
                            Text(allergen)
                        }
                    }
                }

                /// Dietary information section, displayed only if dietary info is present
                if let dietaryInfo = item.dietary_info, !dietaryInfo.isEmpty {
                    Section(header: Text("Dietary Info")) {
                        ForEach(dietaryInfo, id: \.self) { tag in
                            Text(tag)
                        }
                    }
                }

                /// Sizes and prices section, displayed only if sizes are defined
                if !item.sizes.isEmpty {
                    Section(header: Text("Sizes & Prices")) {
                        ForEach(item.sizes.indices, id: \.self) { index in
                            let size = item.sizes[index]
                            HStack {
                                Text(size.size ?? "Regular")
                                Spacer()
                                Text(String(format: "$%.2f", size.price ?? 0.0))
                            }
                        }
                    }
                }

                /// Add-ons section, displayed only if add-ons are available
                if let addons = item.addons, !addons.isEmpty {
                    Section(header: Text("Add-ons")) {
                        ForEach(addons, id: \.name) { addon in
                            VStack(alignment: .leading) {
                                Text(addon.name)
                                    .fontWeight(.medium)
                                if let price = addon.price {
                                    Text(String(format: "$%.2f", price))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
