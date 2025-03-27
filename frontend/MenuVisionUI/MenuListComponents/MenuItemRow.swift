import SwiftUI

struct MenuItemRow: View {
    let item: MenuItem
    @State private var showDetail = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .cornerRadius(8)

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
        .sheet(isPresented: $showDetail) {
            MenuItemDetailView(item: item)
        }
    }

    func colorForPrice(_ price: Double) -> Color {
        if price == 0 { return .red }
        else if price < 10 { return .yellow }
        else { return .gray }
    }
}
