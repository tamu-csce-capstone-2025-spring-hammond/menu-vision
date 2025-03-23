//
//  SignupView.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/20/25.
//

import SwiftUI
//
//struct SignupView: View {
//    @Binding var isLoggedIn: Bool
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .center, spacing: 0) {
//                // Header section with background image
//                ZStack(alignment: .top) {
//                    // Background image
//                    AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/3fa88cbcfc66228ad426e66cc7aeb5faa84f1791?placeholderIfAbsent=true&format=webp")) { phase in
//                        switch phase {
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                        case .failure(_):
//                            Color.gray.opacity(0.3)
//                        case .empty:
//                            Color.gray.opacity(0.1)
//                        @unknown default:
//                            Color.gray.opacity(0.1)
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                    .aspectRatio(0.821, contentMode: .fit)
//
//                    VStack(spacing: 0) {
//                        // Logo and title
//                        HStack(spacing: 12) {
//                            Text("Menu")
//                                .font(.system(size: 16, weight: .heavy))
//                                .tracking(3.84)
//                                .foregroundColor(Color.customZinc700)
//
//                            HStack(spacing: 4) {
//                                AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/e912b16b54a45bfba071cf318321d92311575335?placeholderIfAbsent=true&format=webp")) { phase in
//                                    switch phase {
//                                    case .success(let image):
//                                        image
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                    case .failure(_):
//                                        Color.gray.opacity(0.3)
//                                    case .empty:
//                                        Color.gray.opacity(0.1)
//                                    @unknown default:
//                                        Color.gray.opacity(0.1)
//                                    }
//                                }
//                                .frame(width: 30, height: 30)
//
//                                Text("Vision")
//                                    .font(.system(size: 16, weight: .heavy))
//                                    .tracking(3.84)
//                                    .foregroundColor(Color.customZinc700)
//                            }
//                        }
//                        .padding(.top, 48)
//
//                        // Main image
//                        AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/03295b17-fb7f-4bd5-b5fe-e831ea807400?placeholderIfAbsent=true&format=webp")) { phase in
//                            switch phase {
//                            case .success(let image):
//                                image
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                            case .failure(_):
//                                Color.customOrange300.opacity(0.6)
//                                    .aspectRatio(1.14, contentMode: .fit)
//                            case .empty:
//                                Color.customOrange300.opacity(0.6)
//                                    .aspectRatio(1.14, contentMode: .fit)
//                            @unknown default:
//                                Color.customOrange300.opacity(0.6)
//                                    .aspectRatio(1.14, contentMode: .fit)
//                            }
//                        }
//                        .background(Color.customOrange300.opacity(0.6))
//                        .aspectRatio(1.14, contentMode: .fit)
//                        .padding(.top, 32)
//                    }
//                    .padding(.horizontal, 28)
//                }
//                .frame(maxWidth: .infinity)
//
//                // Welcome text
//                Text("Welcome to MenuVision")
//                    .font(.system(size: 24, weight: .bold))
//                    .foregroundColor(Color.customZinc700)
//                    .padding(.top, 48)
//
//                // Description text
//                Text("We Scan Restaurant Menus")
//                    .font(.system(size: 16, weight: .light))
//                    .foregroundColor(Color.customGray400)
//                    .lineSpacing(8)
//                    .padding(.top, 24)
//
//                // Sign up button
//                Button(action: {
//                    // Sign up action
//                }) {
//                    Text("SIGN UP")
//                        .font(.system(size: 14))
//                        .tracking(2)
//                        .foregroundColor(Color.white.opacity(0.95))
//                        .frame(maxWidth: 374)
//                        .frame(height: 56)
//                        .background(Color.customOrange300)
//                        .cornerRadius(38)
//                }
//                .padding(.top, 96)
//                .padding(.horizontal, 64)
//
//                // Login text
//                HStack(spacing: 4) {
//                    Text("ALREADY HAVE AN ACCOUNT?")
//                        .foregroundColor(Color.customGray400)
//
//                    Text("LOG IN")
//                        .foregroundColor(Color.customOrange300)
//                }
//                .font(.system(size: 14, weight: .medium))
//                .tracking(2)
//                .padding(.top, 20)
//                .padding(.bottom, 96)
//            }
//            .frame(maxWidth: 480)
//            .background(Color.white)
//        }
//    }
//}


struct SignupView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
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
                        // Sign up action
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

                    // Login text
                    Text("ALREADY HAVE AN ACCOUNT? LOG IN")
                        .font(.system(size: min(14, geometry.size.width * 0.035), weight: .medium))
                        .tracking(2) // tracking-wider
                        .padding(.top, 20)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.clear)
                        .overlay(
                            Text(attributedLoginText())
                        )

                    Spacer(minLength: geometry.size.height * 0.05)
                }
                .frame(minHeight: geometry.size.height)
                .frame(width: geometry.size.width)
                .background(Color.white)
            }
            .edgesIgnoringSafeArea(.top) // Allow the image to extend to the top edge
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
    SignupView(isLoggedIn: .constant(false))
}

