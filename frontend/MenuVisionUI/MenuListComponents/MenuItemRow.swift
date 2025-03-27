import SwiftUI

struct MenuItemRow: View {
    let item: MenuItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Placeholder thumbnail
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .cornerRadius(8)

            // Title and description stack
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)

                Text(item.description ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Right-side price, dot, info icon
            VStack(alignment: .trailing, spacing: 6) {
                Text(String(format: "$%.2f", item.sizes.first?.price ?? 0.0))
                    .font(.subheadline)

                HStack(spacing: 8) {
                    Circle()
                        .fill(colorForPrice(item.sizes.first?.price ?? 0))
                        .frame(width: 12, height: 12)

                    Button(action: {
                        // Future: Show info modal
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
    }

    func colorForPrice(_ price: Double) -> Color {
        if price == 0 { return .red }
        else if price < 10 { return .yellow }
        else { return .gray }
    }
}
