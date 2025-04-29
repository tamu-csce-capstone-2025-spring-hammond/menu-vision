//
//  DietaryRestrictionItem.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/24/25.
//

import SwiftUI

struct DietaryRestrictionItem: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    // Define colors
    private let orangeHighlight = Color(red: 254/255, green: 215/255, blue: 170/255) // Lighter orange than the button
    private let orangeButton = Color(red: 253/255, green: 186/255, blue: 116/255) // Original orange-300

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 33/255, green: 33/255, blue: 33/255)) // text-neutral-800
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(isSelected ? orangeHighlight : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ?
                            Color(red: 214/255, green: 211/255, blue: 209/255) : // border-stone-300
                            Color(red: 197/255, green: 198/255, blue: 204/255), // border-[#C5C6CC]
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ?
                    Color.black.opacity(0.25) :
                    Color.black.opacity(0.05),
                radius: isSelected ? 4 : 1,
                x: 0,
                y: isSelected ? 4 : 1
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DietaryRestrictionItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            DietaryRestrictionItem(
                title: "Dairy Allergy",
                isSelected: true,
                onTap: {}
            )

            DietaryRestrictionItem(
                title: "Gluten Free",
                isSelected: false,
                onTap: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
