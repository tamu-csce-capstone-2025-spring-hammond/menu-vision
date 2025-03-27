import SwiftUI

struct MenuListView: View {
    let response: String
    @State private var parsedMenu: [MenuSection] = []

    var body: some View {
        List {
            ForEach(parsedMenu) { section in
                Section(header: Text(section.name).font(.title3)) {
                    ForEach(section.items) { item in
                        MenuItemRow(item: item)
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
            // Use raw JSON parsing to preserve order
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
