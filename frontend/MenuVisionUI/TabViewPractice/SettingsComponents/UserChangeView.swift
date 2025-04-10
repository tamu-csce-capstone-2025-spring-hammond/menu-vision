//
//  UserChangeView.swift
//  MenuVision
//
//  Created by Albert Yin on 4/10/25.
//

import SwiftUI

struct UserChangeView: View {
    @State private var username: String = ""
        @Environment(\.presentationMode) var presentationMode

        // Custom colors to match the design
        private let textPrimaryColor = Color(red: 31/255, green: 32/255, blue: 36/255) // #1F2024
        private let textSecondaryColor = Color(red: 47/255, green: 48/255, blue: 54/255) // #2F3036
        private let placeholderColor = Color(red: 143/255, green: 144/255, blue: 152/255) // #8F9098
        private let borderColor = Color(red: 197/255, green: 198/255, blue: 204/255) // #C5C6CC
        private let buttonColor = Color(red: 250/255, green: 162/255, blue: 107/255) // #FAA26B

        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Background
                    Color.white.edgesIgnoringSafeArea(.all)

                    VStack(spacing: 0) {
                        // Header with back button and title
                        ZStack(alignment: .center) {
                            // Back button
                            HStack {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(textPrimaryColor)
                                }
                                .padding(.leading, 17)

                                Spacer()
                            }

                            // Title - Using system font with explicit bold styling
                            Text("Change Username")
                                .font(.system(size: 24, weight: .black)) // Using .black for maximum boldness
                                .bold() // Explicit bold modifier
                                .foregroundColor(textPrimaryColor)
                                .padding(.top, 8)
                                .tracking(0.24) // Letter spacing from design
                        }
                        .frame(height: 80)

                        // Form fields
                        VStack(spacing: 16) {
                            // Username field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(textSecondaryColor)

                                ZStack(alignment: .leading) {
                                    if username.isEmpty {
                                        // Using system font with explicit italic styling
                                        Text("username")
                                            .font(.system(size: 14))
                                            .italic() // Explicit italic modifier
                                            .foregroundStyle(placeholderColor) // Using newer API
                                    }

                                    TextField("", text: $username)
                                        .font(.system(size: 14))
                                        .foregroundColor(textSecondaryColor)
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 48)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(borderColor, lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 50)

                        Spacer()

                        // Save button
                        Button(action: {
                            // Handle save action
                            print("Saving username: \(username)")
                        }) {
                            Text("Save")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(buttonColor)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 370)
                    }
                }
                .frame(width: min(414, geometry.size.width))
                .frame(maxWidth: .infinity)
            }
            .navigationBarHidden(true) // Hide the default navigation bar
        }
    }

#Preview {
    UserChangeView()
}
