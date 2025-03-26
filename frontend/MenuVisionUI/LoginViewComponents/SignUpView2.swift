//
//  SignUpView2.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/24/25.
//

import SwiftUI

struct SignUpView2: View {
    // State to track selected cuisines - empty by default
    @State private var selectedCuisines: Set<String> = []
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToSignUpView3 = false

    // List of all available cuisines
    private let cuisines = [
        "Chinese",
        "French",
        "Greek",
        "Indian",
        "Italian",
        "Japanese",
        "Korean",
        "Latin American"
    ]

    // Define colors
    private let orangeHighlight = Color(red: 254/255, green: 215/255, blue: 170/255) // Lighter orange
    private let orangeButton = Color(red: 253/255, green: 186/255, blue: 116/255) // Original orange-300

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                // Add extra space at the top
                Spacer()
                    .frame(height: 50)

                // Progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 226/255, green: 232/255, blue: 240/255)) // bg-slate-200
                        .frame(width: 366, height: 8)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(orangeButton) // bg-orange-300
                        .frame(width: 230, height: 8)
                }
                .padding(.top, 24)

                // Back button - moved below progress bar
                HStack {
                    Button(action: {
                        // Navigate back
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/ca2f1e5c314910e288f793b2b172a0ab972f546e?placeholderIfAbsent=true&format=webp")) { image in
                            image
                                .resizable()
                                .aspectRatio(0.6, contentMode: .fit)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 9)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                }
                .padding(.leading, 0)
                .padding(.top, 18)
                .zIndex(10)

                // Title section
                VStack(alignment: .leading, spacing: 9) {
                    Text("What cuisines do you like?")
                        .font(.system(size: 25, weight: .heavy))
                        .tracking(0.5)
                        .foregroundColor(Color(red: 33/255, green: 33/255, blue: 33/255)) // text-neutral-800

                    Text("MenuVision will recommend you items based off your tastes.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 113/255, green: 113/255, blue: 122/255)) // text-zinc-500
                        .padding(.top, -8) // Adjust for the spacing above
                }
                .frame(width: 358, alignment: .leading)
                .padding(.top, 9) // Reduced from 40 to bring content closer to back button

                // Cuisine list
                VStack(spacing: 8) {
                    ForEach(cuisines, id: \.self) { cuisine in
                        CuisineListItem(
                            title: cuisine,
                            isSelected: selectedCuisines.contains(cuisine),
                            orangeHighlight: orangeHighlight,
                            onTap: {
                                toggleSelection(cuisine)
                            }
                        )
                    }
                }
                .padding(.top, 22) // Reduced from 40 to bring content closer together

                // Bottom button with dynamic text based on selection
                Button(action: {
                    // Action for button - continue to next screen or dismiss
                    navigateToSignUpView3 = true
                }) {
                    Text(selectedCuisines.isEmpty ? "Nope" : "Lets Go!")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(orangeButton) // bg-orange-300
                        )
                }
                .padding(.top, 50)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .navigationBarHidden(true) // Hide the entire navigation bar
        .toolbar(.hidden, for: .navigationBar) // Additional modifier for iOS 16+
        .navigationDestination(isPresented: $navigateToSignUpView3) {
            SignUpView3()
        }
    }

    private func toggleSelection(_ cuisine: String) {
        if selectedCuisines.contains(cuisine) {
            selectedCuisines.remove(cuisine)
        } else {
            selectedCuisines.insert(cuisine)
        }
    }
}

struct CuisineListItem: View {
    let title: String
    let isSelected: Bool
    let orangeHighlight: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 33/255, green: 33/255, blue: 33/255)) // neutral-800
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

#Preview("iPhone 13 Pro") {
    SignUpView2()
}
