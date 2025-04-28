import SwiftUI

/// A view that presents the login interface for user authentication.
///
/// This view handles user authentication by collecting email and password credentials,
/// maintaining login state, and providing navigation to other parts of the app when successful.
struct LoginView: View {
    /// Environment property to access presentation mode for dismissing the view.
    @Environment(\.presentationMode) var presentationMode
    
    /// Access to the shared user state view model.
    @EnvironmentObject var vm: UserStateViewModel
    
    /// The user's email input.
    @State private var email: String = ""
    
    /// The user's password input.
    @State private var password: String = ""
    
    /// Controls whether the password text is displayed or masked.
    @State private var isPasswordVisible: Bool = false
    
    /// Controls whether to remember the user's login state.
    @State private var rememberMe: Bool = false
    
    /// Controls display of alert messages.
    @State private var showingAlert = false
    
    /// Message content for the alert dialog.
    @State private var alertMessage = ""
    
    /// Environment property to dismiss the view.
    @Environment(\.dismiss) var dismiss

    
//    @Binding var isLoggedIn: Bool
    
    /// App storage for persisting user ID between app launches.
    @AppStorage("user_id") private var userId: Int = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Dark background for the entire screen
                Color.slate950
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 0) {
                        // Header section with dark background
                        VStack(alignment: .leading, spacing: 0) {
                            // Back button
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 1)
                            .padding(.bottom, 5)
                            
                            // Logo
                            HStack(spacing: 2) {
                                CustomLogo(width: 18, height: 18, color: Color(hex: "FAAC7B"))

                                    Text("MenuVision")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    }
                            .padding(.top, 5)

                            // Headline
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Welcome Back!")
                                    .font(.system(size: 30, weight: .bold))
                                    .tracking(-0.8)
                                    .foregroundColor(Color.zinc100)

                                Text("Log in to start scanning menus.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 15)
                            .padding(.bottom, 28) // Increased bottom padding to move white box down
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)

                        // Content section with white background
                        VStack(spacing: 0) {
                            // Tab selector
                            HStack(spacing: 0) {
                            }
                            .padding(2)
                            .background(Color.slate100)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.slate100, lineWidth: 1)
                            )

                            // Email field
                            InputField1(
                                title: "Email",
                                placeholder: "Enter your email",
                                text: $email
                            )
                            .padding(.top, 2)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)

                            // Password field
                            InputField1(
                                title: "Password",
                                placeholder: "Enter your password",
                                text: $password,
                                isSecure: !isPasswordVisible,
                                trailingIcon: {
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(Color.neutral400)
                                    }
                                }
                            )
                            .padding(.top, 16)

                            // Remember me and Forgot Password
                            HStack {
                                Button(action: {
                                    rememberMe.toggle()
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                            .resizable()
                                            .frame(width: 19, height: 19)
                                            .foregroundColor(rememberMe ? Color.orange300 : Color.zinc500)

                                        Text("Remember me")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color.zinc500)
                                    }
                                }

                                Spacer()

                                Button(action: {
                                    // Forgot password action
                                    alertMessage = "Password reset functionality would be implemented here"
                                    showingAlert = true
                                }) {
                                    Text("Forgot Password?")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.orange300)
                                }
                            }
                            .padding(.top, 16)

                            // Login button
                            Button(action: {
                                // Use the LoginHandler to validate login
                                LoginHandler.shared.validateLogin(
                                    email: email,
                                    password: password,
                                    rememberMe: rememberMe
                                ) { success, message, userId in
                                    if success {
                                        if let userId = userId {
                                            self.userId = userId
                                        }
                                        vm.isLoggedIn = true
                                        dismiss()
                                    } else if let message = message {
                                        alertMessage = message
                                        showingAlert = true
                                    }
                                }
                            }) {
                                Text("Login")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                            .background(Color.orange300)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .padding(.top, 87)

                            // Don't have an account
                            HStack {
                                Spacer()
                                Text("Don't have an account? ")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.zinc500)

                                Button(action: {
                                    // Navigate back and then to sign up
                                    presentationMode.wrappedValue.dismiss()
                                    // We would need a more complex navigation solution to go directly to sign up
                                }) {
                                    Text("Sign Up")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.orange300)
                                }
                                Spacer()
                            }
                            .padding(.top, 24)
                            .padding(.bottom, 40)

                            Spacer(minLength: 0)
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(16, corners: [.topLeft, .topRight]) // Apply rounded corners to top edges
                        .frame(minHeight: geometry.size.height * 1.5) // Ensure white background extends to bottom
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Message"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            // Check if we should auto login
            if UserDefaults.standard.bool(forKey: "is_logged_in") && userId != 0 {
                vm.isLoggedIn = true
            }
        }
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView(isLoggedIn: .constant(false))
//    }
//}
