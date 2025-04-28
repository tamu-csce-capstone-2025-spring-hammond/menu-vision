import SwiftUI

/// A row component that displays a menu item in a list with its key details and thumbnail
struct MenuItemRow: View {
    /// The menu item to display in this row
    let item: MenuItem
    /// State to track whether the detail view is being shown
    @State private var showDetail = false
    /// State to track whether to navigate to AR view
    @State private var navigateToAR = false
    /// Environment object to access dish mapping data
    @EnvironmentObject var dishMapping: DishMapping
    /// Whether this item is recommended to the user
    let isRecommended: Bool
    /// Whether this item is marked as spicy
    let isSpicy: Bool

    /// The main view body that displays the menu item in a row format
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                /// Thumbnail image with AR button if a model is available
                if let model = item.matchedDishData?.first {
                    let modelID = model.model_id
                    let localImage = loadDishThumbnail(modelID: modelID)

                    Button(action: {
                        dishMapping.setGoTo(id: modelID)
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
                } else {
                    /// Default placeholder image if no model is available
                    ZStack {
                        AsyncImage(url: URL(string: "https://static.vecteezy.com/system/resources/previews/022/059/000/non_2x/no-image-available-icon-vector.jpg")) { phase in
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
                                fallbackRect()
                            }
                        }
                    }
                    .frame(width: 60, height: 60)
                }

                /// Item name and description
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name)
                            .font(.headline)
                        if isRecommended {
                            Text("Rec")
                                .font(.caption)
                                .padding(4)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }

                    Text(item.description ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                /// Price and status indicators
                VStack(alignment: .trailing, spacing: 6) {
                    let sortedPrices = item.sizes.compactMap { $0.price }.sorted()
                    let priceString = sortedPrices.map { String(format: "$%.2f", $0) }.joined(separator: " / ")

                    Text(priceString)
                        .font(.subheadline)

                    HStack(spacing: 8) {
                        if let allergens = item.allergens, !allergens.isEmpty {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 16, height: 16)
                        }
                        
                        if isSpicy {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.red)
                                .frame(width: 16, height: 16)
                        }

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
            .navigationDestination(isPresented: $navigateToAR) {
                FirstTabView().environmentObject(dishMapping)
            }
        }
        .sheet(isPresented: $showDetail) {
            MenuItemDetailView(item: item)
        }
    }

    /// Generates a fallback placeholder rectangle when an image is not available
    /// - Returns: A gray placeholder rectangle with rounded corners
    func fallbackRect() -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 60, height: 60)
            .cornerRadius(8)
    }

    /// Loads a thumbnail image for a dish from the local document directory
    /// - Parameter modelID: The identifier of the model to load the thumbnail for
    /// - Returns: The loaded UIImage if available, otherwise nil
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
}
