//
//  SignUpView.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/23/25.
//

import SwiftUI

/// A view that allows users to select dietary restrictions during the sign-up process.
///
/// This is the first step in the multi-step sign-up flow, where users can select their
/// dietary restrictions that will be used for personalized menu recommendations.
struct SignUpView: View {
    /// Shared data model containing user information collected during sign-up.
    @ObservedObject var signUpData: SignUpData
    
    /// Set of selected dietary restrictions.
    @State private var selectedRestrictions: Set<String> = []
    
    /// Environment property to access presentation mode for dismissing the view.
    @Environment(\.presentationMode) var presentationMode
    
    /// Controls navigation to the next sign-up view.
    @State private var navigateToSignUpView2 = false

    /// List of dietary restriction options that users can select from.
    let dietaryOptions = [
        "Vegetarian",
        "Vegan",
        "Pescatarian",
        "Gluten-Free",
        "Dairy-Free",
        "Nut-Free",
        "Soy-Free",
        "Egg-Free",
        "Lactose Intolerant",
        "Halal",
        "Kosher",
        "No Beef",
        "No Pork",
        "No Red Meat",
        "Low Carb",
        "Low Sugar",
        "Low Sodium"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                Spacer().frame(height: 50)

                // Progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 226/255, green: 232/255, blue: 240/255))
                        .frame(width: 366, height: 8)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 253/255, green: 186/255, blue: 116/255))
                        .frame(width: 126, height: 8)
                }
                .padding(.top, 10)

                // Back button
                HStack {
                    Button(action: {
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

                // Title
                VStack(alignment: .leading, spacing: 9) {
                    Text("Any dietary restrictions?")
                        .font(.system(size: 25, weight: .heavy))
                        .tracking(0.5)
                        .foregroundColor(Color(red: 33/255, green: 33/255, blue: 33/255))

                    Text("Choose your dietary preferences.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 113/255, green: 113/255, blue: 122/255))
                        .padding(.top, -3)
                }
                .frame(width: 358, alignment: .leading)
                .padding(.top, 10)

                // Restriction list
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
                .padding(.top, 22)

                // Button
                Button(action: {
                    signUpData.dietaryRestrictions = selectedRestrictions
                    navigateToSignUpView2 = true
                }) {
                    Text(selectedRestrictions.isEmpty ? "Nope" : "Lets Go!")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 253/255, green: 186/255, blue: 116/255))
                        )
                }
                .padding(.top, 70)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $navigateToSignUpView2) {
            SignUpView2(signUpData: signUpData)
        }
    }

    /// Toggles the selection state of a dietary restriction option.
    ///
    /// - Parameter option: The dietary restriction option to toggle.
    private func toggleSelection(_ option: String) {
        if selectedRestrictions.contains(option) {
            selectedRestrictions.remove(option)
        } else {
            selectedRestrictions.insert(option)
        }
    }
}

#Preview("iPhone 13 Pro") {
    SignUpView(signUpData: SignUpData())
}
