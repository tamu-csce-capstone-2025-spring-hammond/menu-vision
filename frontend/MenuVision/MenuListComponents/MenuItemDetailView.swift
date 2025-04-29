//
//  MenuItemDetailView.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 3/27/25.
//

import SwiftUI

struct MenuItemDetailView: View {
    let item: MenuItem

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Description")) {
                    Text(item.description ?? "No description available.")
                }

                if let spiciness = item.spiciness {
                    Section(header: Text("Spiciness")) {
                        Text(spiciness)
                    }
                }

                if let calories = item.calories {
                    Section(header: Text("Calories")) {
                        Text(calories)
                    }
                }

                if let popularity = item.popularity {
                    Section(header: Text("Popularity")) {
                        Text(popularity)
                    }
                }

                if let availability = item.availability {
                    Section(header: Text("Availability")) {
                        Text(availability)
                    }
                }

                if let allergens = item.allergens, !allergens.isEmpty {
                    Section(header: Text("Allergens")) {
                        ForEach(allergens, id: \.self) { allergen in
                            Text(allergen)
                        }
                    }
                }

                if let dietaryInfo = item.dietary_info, !dietaryInfo.isEmpty {
                    Section(header: Text("Dietary Info")) {
                        ForEach(dietaryInfo, id: \.self) { tag in
                            Text(tag)
                        }
                    }
                }

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
