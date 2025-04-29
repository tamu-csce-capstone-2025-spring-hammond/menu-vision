import SwiftUI

struct PassChangeView: View {
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var passwordsMatch: Bool = true
    @State private var isLoading: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var alertMessage: String = ""
    
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
                        Text("Change Password")
                            .font(.system(size: 24, weight: .black)) // Using .black for maximum boldness
                            .bold() // Explicit bold modifier
                            .foregroundColor(textPrimaryColor)
                            .padding(.top, 8)
                            .tracking(0.24) // Letter spacing from design
                    }
                    .frame(height: 80)

                    // Form fields
                    VStack(spacing: 16) {
                        // New Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Password")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(textSecondaryColor)

                            ZStack(alignment: .leading) {
                                HStack {
                                    if isPasswordVisible {
                                        TextField("", text: $newPassword)
                                            .font(.system(size: 14))
                                            .foregroundColor(textSecondaryColor)
                                    } else {
                                        SecureField("", text: $newPassword)
                                            .font(.system(size: 14))
                                            .foregroundColor(textSecondaryColor)
                                    }
                                    
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(Color.neutral400)
                                    }
                                }
                                
                                if newPassword.isEmpty {
                                    Text("New password")
                                        .font(.system(size: 14))
                                        .italic()
                                        .foregroundStyle(placeholderColor)
                                        .allowsHitTesting(false)
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(borderColor, lineWidth: 1)
                            )
                        }

                        // Confirm Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Password, Again")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(textSecondaryColor)

                            ZStack(alignment: .leading) {
                                HStack {
                                    if isConfirmPasswordVisible {
                                        TextField("", text: $confirmPassword)
                                            .font(.system(size: 14))
                                            .foregroundColor(textSecondaryColor)
                                    } else {
                                        SecureField("", text: $confirmPassword)
                                            .font(.system(size: 14))
                                            .foregroundColor(textSecondaryColor)
                                    }
                                    
                                    Button(action: {
                                        isConfirmPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(Color.neutral400)
                                    }
                                }
                                
                                if confirmPassword.isEmpty {
                                    Text("New password, again")
                                        .font(.system(size: 14))
                                        .italic()
                                        .foregroundStyle(placeholderColor)
                                        .allowsHitTesting(false)
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(borderColor, lineWidth: 1)
                            )
                        }
                        
                        // Password validation message
                        if !passwordsMatch && !confirmPassword.isEmpty {
                            Text("Passwords do not match")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                                .padding(.leading, 2)
                        }

                        // Password Tips
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Password Tips:")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(placeholderColor)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("✔️ 8 to 20 Characters")
                                        .font(.system(size: 11))
                                        .foregroundColor(placeholderColor)

                                    Text("✔️ Letters, numbers, and special characters")
                                        .font(.system(size: 11))
                                        .foregroundColor(placeholderColor)
                                }
                            }
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 50)
                    .onChange(of: confirmPassword) { _ in
                        validatePasswords()
                    }
                    .onChange(of: newPassword) { _ in
                        if !confirmPassword.isEmpty {
                            validatePasswords()
                        }
                    }

                    Spacer()

                    // Save button
                    Button(action: {
                        updatePassword()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(buttonColor)
                                .cornerRadius(12)
                        } else {
                            Text("Save")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(buttonColor)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 300)
                    .disabled(isLoading || newPassword.isEmpty || confirmPassword.isEmpty || !passwordsMatch)
                }
            }
            .frame(width: min(414, geometry.size.width))
            .frame(maxWidth: .infinity)
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK") {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text(alertMessage)
            }
        }
        .navigationBarHidden(true) // Hide the default navigation bar
    }
    
    // Function to validate that passwords match
    private func validatePasswords() -> Bool {
        if newPassword.isEmpty && confirmPassword.isEmpty {
            // Both empty, don't show error yet
            passwordsMatch = true
            return false
        }
        
        let match = newPassword == confirmPassword
        passwordsMatch = match
        return match
    }
    
    // Function to update password
    private func updatePassword() {
        guard validatePasswords() else {
            alertMessage = "Passwords do not match"
            showErrorAlert = true
            return
        }
        
        // Start loading state
        isLoading = true
        
        // Get current user ID
        let userId = UserDefaults.standard.integer(forKey: "user_id")
        
        // Call the hash API to securely hash the password before sending to server
        guard let hashURL = URL(string: "https://api.algobook.info/v1/crypto/hash?plain=\(newPassword)") else {
            alertMessage = "Invalid hashing URL"
            showErrorAlert = true
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: hashURL) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Hashing failed: \(error.localizedDescription)"
                    showErrorAlert = true
                    isLoading = false
                }
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let hashedPassword = json["hashed"] as? String else {
                DispatchQueue.main.async {
                    alertMessage = "Failed to parse hash response"
                    showErrorAlert = true
                    isLoading = false
                }
                return
            }
            print(hashedPassword)

            let payload: [String: Any] = [
                "hashed_password": hashedPassword
            ]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
                DispatchQueue.main.async {
                    alertMessage = "Failed to prepare update payload"
                    showErrorAlert = true
                    isLoading = false
                }
                return
            }

            // Call API to update password
            API.shared.request(
                endpoint: "user/\(userId)",
                method: "PUT",
                body: jsonData,
                headers: ["Content-Type": "application/json"]
            ) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    switch result {
                    case .success:
                        alertMessage = "Password updated successfully"
                        showSuccessAlert = true
                    case .failure(let error):
                        alertMessage = "Failed to update password: \(error.localizedDescription)"
                        showErrorAlert = true
                    }
                }
            }
        }.resume()
    }
}

// Allow preview
#Preview {
    PassChangeView()
}
