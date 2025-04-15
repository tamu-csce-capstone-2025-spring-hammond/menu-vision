//
//  RestrictChangeView.swift
//  MenuVision
//
//  Created by Albert Yin on 4/10/25.
//

import SwiftUI

struct RestrictChangeView: View {
    // State to track selected dietary restrictions
    @State private var selectedRestrictions: Set<String> = []
        @Environment(\.presentationMode) var presentationMode

        // List of all dietary restrictions
        private let dietaryRestrictions = [
            "Dairy Allergy",
            "Gluten Free",
            "Halal",
            "Kosher",
            "Lactose Intolerant",
            "No Beef",
            "No Pork",
            "No Red Meat"
        ]

        var body: some View {
            // Use ZStack to ensure we have full control over the layout
            ZStack {
                // Main content
                VStack(spacing: 0) {
                    // Header section with custom back button
                    VStack(alignment: .leading, spacing: 0) {
                        // Only black arrow back button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .buttonStyle(PlainButtonStyle())

                        Text("Update Dietary Restrictions")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(Color.titleText)
                            .kerning(0.2)
                            .padding(.top, 12)
                            .lineLimit(1)

                        Text("Choose your dietary preferences.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.subtitleText)
                            .padding(.top, 4)
                    }
                    .padding(.leading, 23)
                    .padding(.trailing, 75)
                    .padding(.top, 25)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // List of dietary restrictions - moved up
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            // Reduced empty space at the top
                            Rectangle()
                                .frame(width: 327, height: 20)
                                .opacity(0)
                                .padding(.top, 10)

                            // Dietary restriction options
                            ForEach(dietaryRestrictions, id: \.self) { restriction in
                                RestrictionItem(
                                    title: restriction,
                                    isSelected: selectedRestrictions.contains(restriction),
                                    onTap: {
                                        toggleSelection(restriction)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    }

                    // Reduced spacer to move content up
                    Spacer(minLength: 10)

                    // Update button
                    Button(action: {
                        // Handle update action
                        print("Selected restrictions: \(selectedRestrictions)")
                    }) {
                        Text("Update")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .padding(.horizontal, 16)
                            .background(Color.buttonBackground)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                }
            }
            .background(Color.white)
            .frame(maxWidth: 480)
            .edgesIgnoringSafeArea(.bottom)
            // Hide the default navigation bar back button if this view is in a NavigationView
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }

        private func toggleSelection(_ restriction: String) {
            if selectedRestrictions.contains(restriction) {
                selectedRestrictions.remove(restriction)
            } else {
                selectedRestrictions.insert(restriction)
            }
        }
    }

    // Nested dietary restriction item component
    extension RestrictChangeView {
        struct RestrictionItem: View {
            let title: String
            let isSelected: Bool
            let onTap: () -> Void

            var body: some View {
                Button(action: onTap) {
                    HStack(spacing: 16) {
                        Text(title)
                            .font(.system(size: 14))
                            .foregroundColor(Color.itemTextColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)

                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.buttonBackground)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(isSelected ? Color.orangeHighlight : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.selectedBorderColor : Color.borderColor,
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
    }

    // Define custom colors
    private extension Color {
        static let titleText = Color(red: 31/255, green: 32/255, blue: 36/255) // #1F2024
        static let subtitleText = Color(red: 113/255, green: 114/255, blue: 122/255) // #71727A
        static let borderColor = Color(red: 197/255, green: 198/255, blue: 204/255) // #C5C6CC
        static let buttonBackground = Color(red: 250/255, green: 162/255, blue: 107/255) // #FAA26B
        static let orangeHighlight = Color(red: 254/255, green: 215/255, blue: 170/255) // Lighter orange
        static let selectedBorderColor = Color(red: 214/255, green: 211/255, blue: 209/255) // border-stone-300
        static let itemTextColor = Color(red: 33/255, green: 33/255, blue: 33/255) // text-neutral-800
    }

#Preview {
    RestrictChangeView()
}
