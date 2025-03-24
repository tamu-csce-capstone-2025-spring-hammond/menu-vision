import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Back button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(red: 0.98, green: 0.67, blue: 0.48)) // Same orange color
                    }
                    .padding(.top, 20)

                    // Title
                    Text("Welcome Back")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.29, green: 0.29, blue: 0.29))
                        .padding(.top, 20)

                    // Form fields
                    VStack(spacing: 20) {
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.63, green: 0.64, blue: 0.7))

                            TextField("Enter your email", text: $email)
                                .padding()
                                .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                                .cornerRadius(10)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.63, green: 0.64, blue: 0.7))

                            SecureField("Enter your password", text: $password)
                                .padding()
                                .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                                .cornerRadius(10)
                        }

                        // Remember me and Forgot password
                        HStack {
                            Toggle("", isOn: $rememberMe)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.98, green: 0.67, blue: 0.48)))

                            Text("Remember me")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.63, green: 0.64, blue: 0.7))

                            Spacer()

                            Button(action: {
                                // Forgot password action
                            }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.98, green: 0.67, blue: 0.48))
                            }
                        }
                    }
                    .padding(.top, 20)

                    // Login button
                    Button(action: {
                        // Login action
                    }) {
                        Text("LOG IN")
                            .font(.system(size: 16, weight: .semibold))
                            .tracking(1.5)
                            .foregroundColor(Color(red: 0.98, green: 0.96, blue: 0.99))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0.98, green: 0.67, blue: 0.48))
                            .cornerRadius(38)
                    }
                    .padding(.top, 30)

                    // Don't have an account
                    HStack {
                        Spacer()
                        Text("Don't have an account? ")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.63, green: 0.64, blue: 0.7))

                        Button(action: {
                            // Navigate back and then to sign up
                            presentationMode.wrappedValue.dismiss()
                            // We would need a more complex navigation solution to go directly to sign up
                        }) {
                            Text("Sign Up")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.98, green: 0.67, blue: 0.48))
                        }
                        Spacer()
                    }
                    .padding(.top, 20)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .frame(minHeight: geometry.size.height)
            }
        }
        .navigationBarHidden(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
