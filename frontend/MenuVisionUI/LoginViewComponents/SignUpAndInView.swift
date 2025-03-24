//
//  SignUpAndInView.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/20/25.
//

import SwiftUI

struct SignUpAndInView: View {
    @State private var navigationPath = NavigationPath()
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .center, spacing: 0) {
                        // Add extra padding at the top to move everything down slightly
                        Spacer()
                            .frame(height: geometry.size.height * 0.03)

                        // Header image
                        AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/3ec6bc4f-88c8-4af7-ab33-a9b7ae943e35?placeholderIfAbsent=true")) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color(red: 0.97, green: 0.97, blue: 0.97)) // bg-stone-50
                                    .aspectRatio(0.82, contentMode: .fit)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(0.82, contentMode: .fit)
                            case .failure:
                                Rectangle()
                                    .fill(Color(red: 0.97, green: 0.97, blue: 0.97)) // bg-stone-50
                                    .aspectRatio(0.82, contentMode: .fit)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            @unknown default:
                                Rectangle()
                                    .fill(Color(red: 0.97, green: 0.97, blue: 0.97)) // bg-stone-50
                                    .aspectRatio(0.82, contentMode: .fit)
                            }
                        }
                        .frame(width: min(geometry.size.width, 390))

                        // Welcome title
                        Text("Welcome to MenuVision")
                            .font(.system(size: min(24, geometry.size.width * 0.06), weight: .bold))
                            .foregroundColor(Color(red: 0.29, green: 0.29, blue: 0.29)) // text-zinc-700
                            .padding(.top, geometry.size.height * 0.05) // Proportional top padding
                            .lineLimit(1)
                            .multilineTextAlignment(.center)

                        // Subtitle
                        Text("We Scan Restaurant Menus")
                            .font(.system(size: min(16, geometry.size.width * 0.04), weight: .light))
                            .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65)) // text-gray-400
                            .padding(.top, geometry.size.height * 0.02) // Proportional top padding
                            .lineSpacing(4) // Adjusted line spacing
                            .multilineTextAlignment(.center)

                        // Sign up button
                        Button(action: {
                            navigationPath.append("signup")
                        }) {
                            Text("SIGN UP")
                                .font(.system(size: min(14, geometry.size.width * 0.035)))
                                .tracking(2) // tracking-wider
                                .foregroundColor(Color(red: 0.98, green: 0.96, blue: 0.99)) // text-violet-50
                                .frame(width: min(geometry.size.width * 0.8, 330))
                                .frame(height: 56) // Fixed height for button
                                .background(Color(red: 0.98, green: 0.67, blue: 0.48)) // bg-orange-300
                                .cornerRadius(38)
                        }
                        .padding(.top, geometry.size.height * 0.08) // Proportional top padding

                        // Login text with tap gesture
                        Text("ALREADY HAVE AN ACCOUNT? LOG IN")
                            .font(.system(size: min(14, geometry.size.width * 0.035), weight: .medium))
                            .tracking(2) // tracking-wider
                            .padding(.top, 20)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.clear)
                            .overlay(
                                Text(attributedLoginText())
                                    .onTapGesture {
                                        navigationPath.append("login")
                                    }
                            )

                        Spacer(minLength: geometry.size.height * 0.05)
                    }
                    .frame(minHeight: geometry.size.height)
                    .frame(width: geometry.size.width)
                    .background(Color.white)
                }
                .edgesIgnoringSafeArea(.top) // Allow the image to extend to the top edge
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "signup":
                    SignUpView()
                case "login":
                    LoginView()
                default:
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func attributedLoginText() -> AttributedString {
        var accountText = AttributedString("ALREADY HAVE AN ACCOUNT? ")
        accountText.foregroundColor = Color(red: 0.63, green: 0.64, blue: 0.7) // rgba(161,164,178,1)

        var loginText = AttributedString("LOG IN")
        loginText.foregroundColor = Color(red: 0.98, green: 0.67, blue: 0.48) // rgba(250,172,123,1)

        return accountText + loginText
    }
}

#Preview {
    // For preview purposes, provide a constant binding.
    SignUpAndInView(isLoggedIn: .constant(false))
}
