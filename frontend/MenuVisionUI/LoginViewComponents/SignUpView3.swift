//
//  SignUpView3.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/24/25.
//

import SwiftUI

/// A view that collects user personal information during sign-up.
///
/// This is the final step in the multi-step sign-up flow, where users enter
/// their personal information to complete account creation.
struct SignUpView3: View {
    /// Shared data model containing user information collected during sign-up.
    @ObservedObject var signUpData: SignUpData
    
    /// The user's first name.
    @State private var first_name: String = ""
    
    /// The user's last name.
    @State private var last_name: String = ""
    
    /// The user's age.
    @State private var age: String = ""
    
    /// The user's username.
    @State private var username: String = ""
    
    /// The user's email address.
    @State private var email: String = ""
    
    /// The user's password.
    @State private var password: String = ""
    
    /// Value for password confirmation.
    @State private var confirmPassword: String = ""
    
    /// Whether the user has agreed to terms and conditions.
    @State private var agreedToTerms: Bool = false
    
    /// Environment property to access presentation mode for dismissing the view.
    @Environment(\.presentationMode) var presentationMode
    
    /// Controls navigation back to the root view after successful signup.
    @State private var navigateToRoot = false
    
    /// Indicates if passwords match during validation.
    @State private var passwordsMatch: Bool = true
    
    /// Controls display of password mismatch alert.
    @State private var showPasswordMismatchAlert: Bool = false
    
    /// Controls display of signup success alert.
    @State private var showSignupSuccessAlert: Bool = false
    
    /// Message content for the signup success alert.
    @State private var signupSuccessMessage: String = ""

    /// Color used for highlighting selected items.
    private let orangeHighlight = Color(red: 254/255, green: 215/255, blue: 170/255)
    
    /// Color used for the main button.
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
                        .frame(width: 324, height: 8)
                }
                .padding(.top, 24)

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
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(Color(UIColor.darkGray))
                    Text("Create an account to get started!")
                        .font(.system(size: 12))
                        .foregroundColor(Color(UIColor.systemGray))
                }
                .frame(width: 358, alignment: .leading)
                .padding(.top, 9)

                // Form fields
                VStack(spacing: 16) {
                    InputField(title: "First Name", text: $first_name, placeholder: "John")
                    InputField(title: "Last Name", text: $last_name, placeholder: "Doe")
                    InputField(title: "Age", text: $age, placeholder: "e.g. 14")
                    InputField(title: "Email Address", text: $email, placeholder: "name@email.com", keyboardType: .emailAddress)
                    PasswordField(title: "Password", password: $password, placeholder: "Create a password")
                    
                    // Add validation message for confirm password field
                    VStack(alignment: .leading, spacing: 4) {
                        PasswordField(title: "", password: $confirmPassword, placeholder: "Confirm password")
                        
                        if !passwordsMatch {
                            Text("Passwords do not match")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                                .padding(.leading, 2)
                        }
                    }
                }
                .padding(.top, 22)
                
                // Check password match whenever either password field changes
                .onChange(of: password) { _ in
                    validatePasswords()
                }
                .onChange(of: confirmPassword) { _ in
                    validatePasswords()
                }

                CheckboxField(
                    isChecked: $agreedToTerms,
                    text: "I've read and agree with the Terms and Conditions and the Privacy Policy."
                )
                .padding(.top, 55)

                Button(action: {
                    // First, validate the passwords match
                    if !validatePasswords() {
                        showPasswordMismatchAlert = true
                        return
                    }
                    
                    // Store values in shared signUpData
                    signUpData.first_name = first_name
                    signUpData.last_name = last_name
                    signUpData.age = age
                    signUpData.email = email
                    signUpData.password = password

                    sendSignUpData()
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
                Spacer(minLength: 200)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Passwords Don't Match", isPresented: $showPasswordMismatchAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please make sure your passwords match.")
        }
        .alert("Account Created", isPresented: $showSignupSuccessAlert) {
            Button("OK", role: .cancel) {
                // Navigate to root after dismissing the success alert
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    findNavigationController(from: rootViewController)?.popToRootViewController(animated: true)
                }
            }
        } message: {
            Text(signupSuccessMessage)
        }
    }
    
    /// Validates that the password and confirmation password match.
    ///
    /// - Returns: A boolean indicating whether the passwords match.
    private func validatePasswords() -> Bool {
        if password.isEmpty && confirmPassword.isEmpty {
            // Both empty, don't show error yet
            passwordsMatch = true
            return false
        }
        
        let match = password == confirmPassword
        passwordsMatch = match
        return match
    }

    /// Sends sign-up data to the backend API.
    ///
    /// This method first hashes the password for security, then creates a payload with all the
    /// user information and makes an API request to create the new user account.
    private func sendSignUpData() {
        guard let hashURL = URL(string: "https://api.algobook.info/v1/crypto/hash?plain=\(password)") else {
            print("Invalid hashing URL")
            return
        }

        URLSession.shared.dataTask(with: hashURL) { data, response, error in
            if let error = error {
                print("Hashing failed: \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let hashedPassword = json["hashed"] as? String else {
                print("Failed to parse hash response")
                return
            }

            let payload: [String: Any] = [
                "email": signUpData.email,
                "hashed_password": hashedPassword,
                "first_name": signUpData.first_name,
                "last_name": signUpData.last_name,
                "age": Int(signUpData.age) ?? 0,
                "food_restrictions": Array(signUpData.dietaryRestrictions),
                "food_preferences": Array(signUpData.selectedCuisines),
            ]
            
            print(payload)

            guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
                print("Failed to encode signup payload")
                return
            }

            API.shared.request(
                endpoint: "user/signup",
                method: "POST",
                body: jsonData,
                headers: ["Content-Type": "application/json"]
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let message = response["message"] as? String {
                            print("Signup success: \(message)")
                            
                            // Show success notification
                            if let userId = response["user_id"] as? Int {
                                signupSuccessMessage = "Account successfully created for \(first_name) \(last_name)! Your user ID is: \(userId)"
                            } else {
                                signupSuccessMessage = "Your account has been successfully created!"
                            }
                            showSignupSuccessAlert = true
                        } else {
                            print("Signup response missing message")
                            
                            // Generic success message if response doesn't contain specifics
                            signupSuccessMessage = "Your account has been created successfully!"
                            showSignupSuccessAlert = true
                        }
                    case .failure(let error):
                        print("Signup request failed: \(error.localizedDescription)")
                    }
                }
            }

        }.resume()
    }

    /// Recursively finds a navigation controller in the view controller hierarchy.
    ///
    /// - Parameter viewController: The root view controller to start the search from.
    /// - Returns: A navigation controller if one is found, nil otherwise.
    private func findNavigationController(from viewController: UIViewController) -> UINavigationController? {
        if let nav = viewController as? UINavigationController {
            return nav
        }

        for child in viewController.children {
            if let nav = findNavigationController(from: child) {
                return nav
            }
        }

        return nil
    }
}

#Preview("iPhone 13 Pro") {
    SignUpView3(signUpData: SignUpData())
}
