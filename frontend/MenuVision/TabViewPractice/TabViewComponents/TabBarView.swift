//
//  TabBarView.swift
//  MenuVision
//
//  Created by Albert Yin on 4/3/25.
//
import SwiftUI

struct TabBarView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            TabBarItem(
                iconURL: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/8b9f3ed196184a981125a6706fffbc8df95cecd6?placeholderIfAbsent=true",
                title: "Upload Scan",
                isSelected: false
            )

            TabBarItem(
                iconURL: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/c46f013f7d7a196716c2894b4844dffb21840f0a?placeholderIfAbsent=true",
                title: "Scan Menu",
                isSelected: false
            )

            TabBarItem(
                iconURL: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/ae4fe2babd5b2285bd14198cdd477bf7a9b5792a?placeholderIfAbsent=true",
                title: "Settings",
                isSelected: true
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .font(.system(size: 12))
    }
}

struct TabBarItem: View {
    let iconURL: String
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: "\(iconURL)&format=webp")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 20, height: 20)

            Text(title)
                .font(isSelected ? .system(size: 12, weight: .semibold) : .system(size: 12))
                .foregroundColor(isSelected ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(red: 0.4, green: 0.4, blue: 0.4))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TabBarView()
}
