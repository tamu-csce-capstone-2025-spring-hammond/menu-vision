import SwiftUI

struct EmailChangeView: View {
    @State private var email: String = ""
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var vm: UserStateViewModel

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

                        // Title
                        Text("Change Email")
                            .font(.system(size: 24, weight: .black))
                            .bold()
                            .foregroundColor(textPrimaryColor)
                            .padding(.top, 8)
                            .tracking(0.24)
                    }
                    .frame(height: 80)

                    // Form fields
                    VStack(spacing: 16) {
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Update Email")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(textSecondaryColor)

                            ZStack(alignment: .leading) {
                                if email.isEmpty {
                                    Text("email")
                                        .font(.system(size: 14))
                                        .italic()
                                        .foregroundStyle(placeholderColor)
                                }

                                TextField("", text: $email)
                                    .font(.system(size: 14))
                                    .foregroundColor(textSecondaryColor)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .onAppear {
                                        // Initialize with current user data
                                        email = vm.userData.email
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
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 50)

                    Spacer()

                    // Save button
                    Button(action: {
                        updateEmail()
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
                    .padding(.bottom, 370)
                    .disabled(isLoading)
                }
            }
            .frame(width: min(414, geometry.size.width))
            .frame(maxWidth: .infinity)
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func updateEmail() {
        // Validate email
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard isValidEmail(trimmedEmail) else {
            errorMessage = "Please enter a valid email address"
            showErrorAlert = true
            return
        }
        
        // Start loading
        isLoading = true
        
        // Prepare request payload
        let userId = UserDefaults.standard.integer(forKey: "user_id")
        let payload: [String: Any] = ["email": trimmedEmail]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            errorMessage = "Failed to prepare request data"
            showErrorAlert = true
            isLoading = false
            return
        }
        
        // Make API request
        API.shared.request(
            endpoint: "user/\(userId)",
            method: "PUT",
            body: jsonData,
            headers: ["Content-Type": "application/json"]
        ) { result in
            // Ensure UI updates happen on main thread
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    // Update view model data
                    vm.userData.email = trimmedEmail
                    
                    // Dismiss view
                    presentationMode.wrappedValue.dismiss()
                
                case .failure(let error):
                    errorMessage = "Failed to update email: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
        }
    }
    
    // Email validation function
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

#Preview {
    EmailChangeView()
        .environmentObject(UserStateViewModel())
}
