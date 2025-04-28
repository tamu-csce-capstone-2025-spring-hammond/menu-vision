import SwiftUI

/// A view that displays a parsed menu and highlights recommended items.
struct MenuListView: View {
    /// The JSON response string containing menu and recommendation data.
    let response: String
    /// The parsed list of menu sections and their items.
    @State private var parsedMenu: [MenuSection] = []
    /// The list of recommended dish names.
    @State private var parsedRecommendations: [String] = []
    /// Shared environment object containing mapping from dish names to dish data models.
    @EnvironmentObject var dishMapping: DishMapping

    /// The view's body, which constructs a list of menu sections and items.
    var body: some View {
        List {
            ForEach(parsedMenu) { section in
                /// Filters and maps items in a section to include matched dish data if available.
                let displayableItems = section.items.compactMap { item -> MenuItem? in
                    if let matched = dishMapping.modelsByDishName[item.name] {
                        let firstMatch = matched.first!
                        return MenuItem(
                            name: firstMatch.dish_name,
                            description: firstMatch.description,
                            sizes: item.sizes,
                            availability: item.availability,
                            spiciness: item.spiciness,
                            allergens: firstMatch.allergens.components(separatedBy: ", "),
                            dietary_info: item.dietary_info ?? [],
                            calories: firstMatch.nutritional_info,
                            popularity: item.popularity,
                            addons: item.addons ?? [],
                            matchedDishData: matched
                        )
                    } else {
                        return item
                    }
                }

                if !displayableItems.isEmpty {
                    Section(header: Text(section.name).font(.title3)) {
                        ForEach(displayableItems) { item in
                            let isRecommended = parsedRecommendations.contains(item.name)
                            /// Displays each menu item in a row, indicating recommendation and spiciness.
                            MenuItemRow(item: item, isRecommended: isRecommended, isSpicy: item.spiciness != nil && !item.spiciness!.isEmpty)
                        }
                    }
                }
            }
        }
        .navigationTitle("Menu")
        .onAppear {
            /// Decodes the API response once the view appears.
            decodeAPIResponse()
        }
    }

    /// Decodes the JSON API response into menu sections and recommended items.
    func decodeAPIResponse() {
        guard let data = response.data(using: .utf8) else { return }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            /// Prints the entire received JSON data for debugging purposes.
            print("Received Data: \(jsonString)")
        }

        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let menuDict = jsonObject["menu"] as? [String: Any],
               let recommendations = jsonObject["recommendations"] as? [[String: Any]] {

                var orderedSections: [MenuSection] = []
                let decoder = JSONDecoder()

                for case let (key, value as [[String: Any]]) in menuDict {
                    /// Decodes each menu section's items and appends to the ordered sections.
                    let sectionData = try JSONSerialization.data(withJSONObject: value)
                    let items = try decoder.decode([MenuItem].self, from: sectionData)
                    orderedSections.append(MenuSection(name: key, items: items))
                }

                /// Maps the recommended items to their names.
                let recommendedDishNames = recommendations.map { $0["name"] as? String ?? "" }

                DispatchQueue.main.async {
                    self.parsedMenu = orderedSections
                    self.parsedRecommendations = recommendedDishNames
                }
                print(parsedRecommendations)
            } else {
                /// Prints an error message if the JSON structure is not as expected.
                print("JSON structure invalid")
            }
        } catch {
            /// Prints any decoding errors encountered.
            print("Decoding error: \(error)")
        }
    }
}
