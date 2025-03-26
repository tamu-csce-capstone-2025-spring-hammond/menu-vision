//
//  SignUpView3.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/24/25.
//

import SwiftUI

struct SignUpView3: View {
    @State private var name: String = "Luc"
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var agreedToTerms: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToRoot = false

    // Define colors to match SignUpView2
    private let orangeHighlight = Color(red: 254/255, green: 215/255, blue: 170/255) // Lighter orange
    private let orangeButton = Color(red: 253/255, green: 186/255, blue: 116/255) // Original orange-300

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                // Add extra space at the top
                Spacer()
                    .frame(height: 50)

                // Progress bar - updated to match SignUpView2
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 226/255, green: 232/255, blue: 240/255)) // bg-slate-200
                        .frame(width: 366, height: 8)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(orangeButton) // bg-orange-300
                        .frame(width: 324, height: 8)
                }
                .padding(.top, 24)

                // Back button - moved below progress bar to match SignUpView2
                HStack {
                    Button(action: {
                        // Navigate back to SignUpView2
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/ca2f1e5c314910e288f793b2b172a0ab972f546e?placeholderIfAbsent=true&format=webp")) { image in
                            image
                                .resizable()
                                .aspectRatio(0.6, contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .frame(width: 9)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                }
                .padding(.leading, 0)
                .padding(.top, 18)
                .zIndex(10)

                // Title and subtitle
                VStack(alignment: .leading, spacing: 9) {
                    Text("Sign up")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(Color(UIColor.darkGray))

                    Text("Create an account to get started")
                        .font(.system(size: 12))
                        .foregroundColor(Color(UIColor.systemGray))
                }
                .frame(width: 358, alignment: .leading)
                .padding(.top, 9)

                // Form fields
                VStack(spacing: 16) {
                    InputField(
                        title: "Name",
                        text: $name,
                        placeholder: "Name"
                    )

                    InputField(
                        title: "Username",
                        text: $username,
                        placeholder: "username"
                    )

                    InputField(
                        title: "Email Address",
                        text: $email,
                        placeholder: "name@email.com",
                        keyboardType: .emailAddress
                    )

                    PasswordField(
                        title: "Password",
                        password: $password,
                        placeholder: "Create a password"
                    )

                    PasswordField(
                        title: "",
                        password: $confirmPassword,
                        placeholder: "Confirm password"
                    )
                }
                .padding(.top, 22)

                // Terms and conditions checkbox
                CheckboxField(
                    isChecked: $agreedToTerms,
                    text: "I've read and agree with the Terms and Conditions and the Privacy Policy."
                )
                .padding(.top, 55)

                // Sign up button
                Button(action: {
                    // Complete sign up and navigate back to root
                    // This will pop to the root of the navigation stack
                    navigateToRoot = true

                    // Dismiss all the way back to SignUpAndInView
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // Use UIApplication to pop to root if in a NavigationStack
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first?.rootViewController {
                            // Find the navigation controller and pop to root
                            findNavigationController(from: rootViewController)?.popToRootViewController(animated: true)
                        }
                    }
                }) {
                    Text("Sign Up")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(orangeButton)
                        )
                }
                .padding(.top, 32)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // Helper function to find navigation controller
    private func findNavigationController(from viewController: UIViewController) -> UINavigationController? {
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }

        for childViewController in viewController.children {
            if let navigationController = findNavigationController(from: childViewController) {
                return navigationController
            }
        }

        return nil
    }
}

#Preview("iPhone 13 Pro") {
    SignUpView3()
}
