//
//  SignUpView2.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/24/25.
//

import SwiftUI

struct SignUpView2: View {
    @ObservedObject var signUpData: SignUpData
    @State private var selectedCuisines: Set<String> = []
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToSignUpView3 = false

    private let cuisines = [
        "Chinese", "French", "Greek", "Indian",
        "Italian", "Japanese", "Korean", "Vietnamese"
    ]

    private let orangeHighlight = Color(red: 254/255, green: 215/255, blue: 170/255)
    private let orangeButton = Color(red: 253/255, green: 186/255, blue: 116/255)

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
                        .fill(orangeButton)
                        .frame(width: 230, height: 8)
                }
                .padding(.top, 10)

                // Back button
                HStack {
                    Button(action: {
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

                // Title
                VStack(alignment: .leading, spacing: 9) {
                    Text("What cuisines do you like?")
                        .font(.system(size: 25, weight: .heavy))
                        .tracking(0.5)
                        .foregroundColor(Color(red: 33/255, green: 33/255, blue: 33/255))

                    Text("MenuVision will recommend you items based off your tastes.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 113/255, green: 113/255, blue: 122/255))
                        .padding(.top, -3)
                }
                .frame(width: 358, alignment: .leading)
                .padding(.top, 10)

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
                .padding(.top, 22)

                // Bottom Button
                Button(action: {
                    signUpData.selectedCuisines = selectedCuisines
                    navigateToSignUpView3 = true
                }) {
                    Text(selectedCuisines.isEmpty ? "Nope" : "Lets Go!")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(orangeButton)
                        )
                }
                .padding(.top, 50)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $navigateToSignUpView3) {
            SignUpView3(signUpData: signUpData)
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
                    .foregroundColor(Color(red: 33/255, green: 33/255, blue: 33/255))
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
                            Color(red: 214/255, green: 211/255, blue: 209/255) :
                            Color(red: 197/255, green: 198/255, blue: 204/255),
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
    SignUpView2(signUpData: SignUpData())
}
