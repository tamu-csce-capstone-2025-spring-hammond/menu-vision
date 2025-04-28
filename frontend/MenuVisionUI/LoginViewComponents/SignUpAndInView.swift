//
//  SignUpAndInView.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/20/25.
//

import SwiftUI

/// A view that provides options for users to either log in or sign up for the app.
///
/// This view serves as the initial navigation screen for unauthenticated users,
/// offering navigation paths to either the sign-up flow or the login screen.
struct SignUpAndInView: View {
    /// Navigation path for handling navigation between views.
    @State private var navigationPath = NavigationPath()
    
    /// Access to the shared user state view model.
    @EnvironmentObject var vm: UserStateViewModel


    // Initialize with a default value for preview
//    init(isLoggedIn: Binding<Bool> = .constant(false)) {
//        self._isLoggedIn = isLoggedIn
//    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .center, spacing: 0) {
                        Spacer()
                            .frame(height: geometry.size.height * 0.02)

                        AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/3ec6bc4f-88c8-4af7-ab33-a9b7ae943e35?placeholderIfAbsent=true")) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color(red: 0.97, green: 0.97, blue: 0.97))
                                    .aspectRatio(0.82, contentMode: .fit)
                            case .success(let image):
                                image
                                    .resizable()
                                    .interpolation(.high)
                                    .aspectRatio(0.82, contentMode: .fit)
                            case .failure:
                                Rectangle()
                                    .fill(Color(red: 0.97, green: 0.97, blue: 0.97))
                                    .aspectRatio(0.82, contentMode: .fit)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            @unknown default:
                                Rectangle()
                                    .fill(Color(red: 0.97, green: 0.97, blue: 0.97))
                                    .aspectRatio(0.82, contentMode: .fit)
                            }
                        }
                        .frame(width: min(geometry.size.width, 490))

                        Text("Welcome to MenuVision")
                            .font(.system(size: min(24, geometry.size.width * 0.06), weight: .bold))
                            .foregroundColor(Color(red: 0.29, green: 0.29, blue: 0.29))
                            .padding(.top, geometry.size.height * 0.05)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)

                        Text("We Scan Restaurant Menus")
                            .font(.system(size: min(16, geometry.size.width * 0.04), weight: .light))
                            .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65))
                            .padding(.top, geometry.size.height * 0.02)
                            .lineSpacing(4)
                            .multilineTextAlignment(.center)

                        // LOGIN button (main)
                        Button(action: {
                            navigationPath.append("login")
                        }) {
                            Text("LOG IN")
                                .font(.system(size: min(14, geometry.size.width * 0.035), weight:.medium))
                                .tracking(2)
                                .foregroundColor(Color(red: 0.98, green: 0.96, blue: 0.99))
                                .frame(width: min(geometry.size.width * 0.8, 330))
                                .frame(height: 56)
                                .background(Color(red: 0.98, green: 0.67, blue: 0.48))
                                .cornerRadius(38)
                        }
                        .padding(.top, geometry.size.height * 0.12)

                        // Bottom Sign Up Text
                        Text("DON'T HAVE AN ACCOUNT? SIGN UP")
                            .font(.system(size: min(14, geometry.size.width * 0.035), weight: .medium))
                            .tracking(2)
                            .padding(.top, 40)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.clear)
                            .overlay(
                                Text(attributedSignUpText())
                                    .onTapGesture {
                                        navigationPath.append("signup")
                                    }
                            )

                        Spacer(minLength: geometry.size.height * 0.05)
                    }
                    .frame(minHeight: geometry.size.height)
                    .frame(width: geometry.size.width)
                    .background(Color.white)
                }
                .edgesIgnoringSafeArea(.top)
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "signup":
                    SignUpView(signUpData: SignUpData())
                case "login":
                    LoginView()
                default:
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $vm.isLoggedIn) {
            HomeView()
        }
    }

    /// Creates an attributed string for the sign-up text with different styling for different parts.
    ///
    /// - Returns: An AttributedString with "DON'T HAVE AN ACCOUNT?" in gray and "SIGN UP" in orange.
    private func attributedSignUpText() -> AttributedString {
        var noAccountText = AttributedString("DON'T HAVE AN ACCOUNT? ")
        noAccountText.foregroundColor = Color(red: 0.63, green: 0.64, blue: 0.7)

        var signUpText = AttributedString("SIGN UP")
        signUpText.foregroundColor = Color(red: 0.98, green: 0.67, blue: 0.48)

        return noAccountText + signUpText
    }
}

#Preview {
    SignUpAndInView()
}
