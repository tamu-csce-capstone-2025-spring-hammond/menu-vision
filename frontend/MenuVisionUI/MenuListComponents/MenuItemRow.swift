import SwiftUI

struct MenuItemRow: View {
    let item: MenuItem
    @State private var showDetail = false
    @State private var navigateToAR = false
    @State private var fetchedImageURL: URL?

    @EnvironmentObject var dishMapping: DishMapping

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                if let model = item.matchedDishData?.first {
                    let modelID = model.model_id
                    let localImage = loadDishThumbnail(modelID: modelID)

                    Button(action: {
                        navigateToAR = true
                    }) {
                        ZStack(alignment: .topTrailing) {
                            if let image = localImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipped()
                                    .cornerRadius(8)
                            } else {
                                fallbackRect()
                            }

                            Image(systemName: "arkit")
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .offset(x: 5, y: -6)
                        }
                        .frame(width: 60, height: 60)
                    }
                    .buttonStyle(PlainButtonStyle())
                } 
                else {
                    ZStack {
                        if let imageURL = fetchedImageURL {
                            AsyncImage(url: imageURL, transaction: .init(animation: .easeInOut)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView().frame(width: 60, height: 60)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipped()
                                        .cornerRadius(8)
                                case .failure:
                                    fallbackRect()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            fallbackRect()
                        }
                    }
                    .frame(width: 60, height: 60)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                    Text(item.description ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(String(format: "$%.2f", item.sizes.first?.price ?? 0.0))
                        .font(.subheadline)

                    HStack(spacing: 8) {
                        Circle()
                            .fill(colorForPrice(item.sizes.first?.price ?? 0))
                            .frame(width: 12, height: 12)

                        Button(action: {
                            showDetail = true
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.gray)
                        }

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    }
                }
            }
            .padding(.vertical, 8)

            NavigationLink(
                destination: FirstTabView().environmentObject(dishMapping),
                isActive: $navigateToAR
            ) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .hidden()
        }
        .sheet(isPresented: $showDetail) {
            MenuItemDetailView(item: item)
        }
        .task {
            if item.matchedDishData?.isEmpty ?? true && fetchedImageURL == nil {
                await fetchImageURLFromBackend(for: item.name)
            }
        }
    }

    func fallbackRect() -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 60, height: 60)
            .cornerRadius(8)
    }

    func colorForPrice(_ price: Double) -> Color {
        if price == 0 { return .red }
        else if price < 10 { return .yellow }
        else { return .gray }
    }

    func loadDishThumbnail(modelID: String) -> UIImage? {
        let fileManager = FileManager.default
        let filename = "\(modelID).png"
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let fileURL = documentsURL.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        }

        return nil
    }

    func fetchImageURLFromBackend(for dishName: String) async {
        let cleanedName = dishName
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9 ]", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
        
        guard let encoded = cleanedName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/ar/get_image?dish_name=\(encoded)") else {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let urlString = json["image_url"] as? String,
               let imageURL = URL(string: urlString) {
                DispatchQueue.main.async {
                    self.fetchedImageURL = imageURL
                }
            }
        } catch {
            print("Failed to fetch image URL for \(dishName): \(error)")
        }
    }
}
