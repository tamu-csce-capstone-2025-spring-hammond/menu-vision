//
//  PrefChangeView.swift
//  MenuVision
//
//  Created by Albert Yin on 4/10/25.
//
import SwiftUI

struct PrefChangeView: View {
    @State private var selectedCuisines: Set<String> = []
    @EnvironmentObject var vm: UserStateViewModel

        @Environment(\.presentationMode) var presentationMode

        // List of available cuisines
        private let cuisines = [
            "American",
            "Chinese",
            "French",
            "Greek",
            "Indian",
            "Italian",
            "Japanese",
            "Korean",
            "Mexican",
            "Middle Eastern",
            "Spanish",
            "Thai",
            "Vietnamese"
        ]

        var body: some View {
            VStack(spacing: 0) {
                // Header section
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .medium))
                    }

                    Text("Update Cuisine Preferences")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(Color.titleText)
                        .kerning(0.2)
                        .padding(.top, 12)
                        .lineLimit(1)

                    Text("MenuVision will recommend you items based off your tastes.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.subtitleText)
                        .padding(.top, 4)
                }
                .padding(.leading, 23)
                .padding(.trailing, 75)
                .padding(.top, 0)
                .frame(maxWidth: .infinity, alignment: .leading)

                // List of cuisine preferences
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        // Reduced empty space at the top
                        Rectangle()
                            .frame(width: 327, height: 20)
                            .opacity(0)
                            .padding(.top, 10)

                        // Cuisine options
                        ForEach(cuisines, id: \.self) { cuisine in
                            CuisineItem(
                                title: cuisine,
                                isSelected: selectedCuisines.contains(cuisine),
                                onTap: {
                                    toggleSelection(cuisine)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                }

                // Reduced spacer to move content up
                Spacer(minLength: 10)

                // Update button
                Button(action: {
                    updatePreferences()
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
                .padding(.top, 10)
                .padding(.top, 10)
                .padding(.bottom, 20)
            }
            .background(Color.white)
            .frame(maxWidth: 480)
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onAppear {
                // Initialize selected restrictions from UserStateViewModel
                selectedCuisines = Set(vm.userData.food_preferences)
                    }
        }

        private func toggleSelection(_ cuisine: String) {
            if selectedCuisines.contains(cuisine) {
                selectedCuisines.remove(cuisine)
            } else {
                selectedCuisines.insert(cuisine)
            }
        }

        private func updatePreferences() {
            // Here you would implement the logic to save the selected preferences
            print("Updated preferences: \(selectedCuisines)")
        }
    }

    // Nested cuisine item component
    extension PrefChangeView {
        struct CuisineItem: View {
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
    PrefChangeView()
}
