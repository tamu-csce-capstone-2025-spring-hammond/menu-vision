import SwiftUI

/// A view representing a single settings item row, displaying a title and a trailing icon.
struct SettingsItemView: View {
    /// The title text displayed on the left side.
    let title: String
    
    /// The URL for the trailing icon image.
    let iconURL: String
    
    /// The environment object managing user state.
    @EnvironmentObject var vm: UserStateViewModel

    /// The body of the `SettingsItemView`.
    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)

            AsyncImage(url: URL(string: "\(iconURL)&format=webp")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 12, height: 12)
        }
        .padding(16)
    }
}

/// A custom divider view that loads a divider image or shows a placeholder if unavailable.
struct Divider: View {
    /// The body of the `Divider`.
    var body: some View {
        AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/abe9dbdf2b096be9060e6e77bd81824b0497c376?placeholderIfAbsent=true&format=webp")) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
        }
    }
}

/// A preview provider for `SettingsItemView` and `Divider`.
struct SettingsItemView_Previews: PreviewProvider {
    /// The previews for settings items and divider.
    static var previews: some View {
        VStack {
            SettingsItemView(
                title: "Name Albert Yin",
                iconURL: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/6f7c5c6258ff91b32ce8094789c38f26145bb0e9?placeholderIfAbsent=true"
            )
            Divider()
            SettingsItemView(
                title: "Username @Alberty3",
                iconURL: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/11a7c5f6112b6118688ced18bc061843134a4eba?placeholderIfAbsent=true"
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
