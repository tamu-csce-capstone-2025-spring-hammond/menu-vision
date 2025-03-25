//
//  SignUpView.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/23/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var selectedRestrictions: Set<String> = []
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToSignUpView2 = false

    let dietaryOptions = [
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
                        .fill(Color(red: 253/255, green: 186/255, blue: 116/255)) // bg-orange-300
                        .frame(width: 126, height: 8)
                }
                .padding(.top, 24)

                // Back button - moved below progress bar
                HStack {
                    Button(action: {
                        // Navigate back to SignUpAndInView
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/b1c514e5da7aa07687c0633cdd64b564107ccdde?placeholderIfAbsent=true&format=webp")) { image in
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
                    Text("Any dietary restrictions?")
                        .font(.system(size: 25, weight: .heavy))
                        .tracking(0.5)
                        .foregroundColor(Color(red: 33/255, green: 33/255, blue: 33/255)) // text-neutral-800

                    Text("Choose your dietary preferences.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 113/255, green: 113/255, blue: 122/255)) // text-zinc-500
                        .padding(.top, -8) // Adjust for the spacing above
                }
                .frame(width: 358, alignment: .leading)
                .padding(.top, 9) // Reduced from 40 to bring content closer to back button

                // Dietary restrictions list
                VStack(spacing: 8) {
                    ForEach(dietaryOptions, id: \.self) { option in
                        DietaryRestrictionItem(
                            title: option,
                            isSelected: selectedRestrictions.contains(option),
                            onTap: {
                                toggleSelection(option)
                            }
                        )
                    }
                }
                .padding(.top, 22) // Reduced from 40 to bring content closer together

                // Bottom button with dynamic text based on selection
                Button(action: {
                    // Navigate to SignUpView2
                    navigateToSignUpView2 = true
                }) {
                    Text(selectedRestrictions.isEmpty ? "Nope" : "Lets Go!")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 253/255, green: 186/255, blue: 116/255)) // bg-orange-300
                        )
                }
                .padding(.top, 70)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .navigationBarHidden(true) // Hide the entire navigation bar
        .toolbar(.hidden, for: .navigationBar) // Additional modifier for iOS 16+
        .navigationDestination(isPresented: $navigateToSignUpView2) {
            SignUpView2()
        }
    }

    private func toggleSelection(_ option: String) {
        if selectedRestrictions.contains(option) {
            selectedRestrictions.remove(option)
        } else {
            selectedRestrictions.insert(option)
        }
    }
}

#Preview("iPhone 13 Pro") {
    SignUpView()
}
