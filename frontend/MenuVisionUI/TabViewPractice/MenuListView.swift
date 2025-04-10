import SwiftUI

struct MenuListView: View {
    let response: String
    @State private var parsedMenu: [MenuSection] = []
    @State private var parsedRecommendations: [String] = [] // Store recommended dish names
    @EnvironmentObject var dishMapping: DishMapping

    var body: some View {
        List {
            ForEach(parsedMenu) { section in
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
                            let isRecommended = parsedRecommendations.contains(item.name) // Check if item is recommended
                            MenuItemRow(item: item, isRecommended: isRecommended) // Pass the recommendation flag
                        }
                    }
                }
            }
        }
        .navigationTitle("Menu")
        .onAppear {
            decodeAPIResponse()
        }
    }

    func decodeAPIResponse() {
        guard let data = response.data(using: .utf8) else { return }

        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let menuDict = jsonObject["menu"] as? [String: Any],
               let recommendations = jsonObject["recommendations"] as? [[String: Any]] {

                var orderedSections: [MenuSection] = []
                let decoder = JSONDecoder()

                for case let (key, value as [[String: Any]]) in menuDict {
                    let sectionData = try JSONSerialization.data(withJSONObject: value)
                    let items = try decoder.decode([MenuItem].self, from: sectionData)
                    orderedSections.append(MenuSection(name: key, items: items))
                }

                let recommendedDishNames = recommendations.map { $0["name"] as? String ?? "" }

                DispatchQueue.main.async {
                    self.parsedMenu = orderedSections
                    self.parsedRecommendations = recommendedDishNames
                }
            } else {
                print("JSON structure invalid")
            }
        } catch {
            print("Decoding error: \(error)")
        }
    }
}
