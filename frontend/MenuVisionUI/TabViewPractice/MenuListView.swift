import SwiftUI

struct MenuListView: View {
    let response: String
    @State private var parsedMenu: [MenuSection] = []
    @EnvironmentObject var dishMapping: DishMapping

    var body: some View {
        List {
            ForEach(parsedMenu) { section in
                Section(header: Text(section.name).font(.title3)) {
                    ForEach(section.items) { item in
                        if let matchedDishData = dishMapping.modelsByDishName[item.name],
                           let verified = matchedDishData.first {
                            // Use verified DishData to override OCR MenuItem
                            let overriddenItem = MenuItem(
                                name: verified.dish_name,
                                description: verified.description,
                                sizes: item.sizes, // You can parse verified.price if needed
                                availability: item.availability,
                                spiciness: item.spiciness,
                                allergens: verified.allergens.components(separatedBy: ", "),
                                dietary_info: item.dietary_info ?? [],
                                calories: verified.nutritional_info,
                                popularity: item.popularity,
                                addons: item.addons ?? []
                            )
                            MenuItemRow(item: overriddenItem)
                        } else {
                            // Fallback to original OCR item
                            MenuItemRow(item: item)
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
               let menuDict = jsonObject["menu"] as? [String: Any] {

                var orderedSections: [MenuSection] = []
                let decoder = JSONDecoder()

                for case let (key, value as [[String: Any]]) in menuDict {
                    let sectionData = try JSONSerialization.data(withJSONObject: value)
                    let items = try decoder.decode([MenuItem].self, from: sectionData)
                    orderedSections.append(MenuSection(name: key, items: items))
                }

                DispatchQueue.main.async {
                    self.parsedMenu = orderedSections
                }

            } else {
                print("JSON structure invalid")
            }
        } catch {
            print("Decoding error: \(error)")
        }
    }
}
