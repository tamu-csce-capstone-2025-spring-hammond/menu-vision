import SwiftUI

struct LoginView: View {
    // This binding is controlled by the parent view (e.g., ContentView) to switch between login and home screens.
    @Binding var isLoggedIn: Bool
    @StateObject private var viewModel: LoginViewModel

    init(isLoggedIn: Binding<Bool>) {
        self._isLoggedIn = isLoggedIn
        let vm = LoginViewModel()
        // Set the login success callback to update the parent's binding.
        vm.onLoginSuccess = {
            isLoggedIn.wrappedValue = true
        }
        _viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Section
                ZStack(alignment: .top) {
                    AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/da303a0268f349fd84e7ed4a5889eb71/96a4a47e832365a633e1eb8e215946aaeaa378c7a4d172e7605dc97fbdb89e93?placeholderIfAbsent=true&format=webp")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 300)

                    VStack(spacing: 32) {
                        // Logo
                        HStack(spacing: 2) {
                            AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/da303a0268f349fd84e7ed4a5889eb71/261bfc14d9c7440438ed2b7498fb892c93b6366fdc83c5eef212c02eba01f4d2?placeholderIfAbsent=true&format=webp")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 18, height: 18)
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }

                            Text("MenuVision")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }

                        // Headline
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Get Started now")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)

                            Text("Create an account or log in to explore about our app")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 64)
                }

                // Content Section
                VStack(spacing: 24) {
                    // Login/Signup Toggle
                    HStack {
                        Button(action: { viewModel.isLoginMode = true }) {
                            Text("Log In")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(viewModel.isLoginMode ? Color.white : Color.clear)
                                .foregroundColor(viewModel.isLoginMode ? .primary : .gray)
                                .cornerRadius(8)
                        }

                        Button(action: { viewModel.isLoginMode = false }) {
                            Text("Sign Up")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(!viewModel.isLoginMode ? Color.white : Color.clear)
                                .foregroundColor(!viewModel.isLoginMode ? .primary : .gray)
                                .cornerRadius(8)
                        }
                    }
                    .background(Color.customGray)
                    .cornerRadius(12)

                    // Form Fields
                    VStack(spacing: 16) {
                        CustomTextField(
                            title: "Email",
                            placeholder: "Enter your email",
                            text: $viewModel.email
                        )

                        CustomTextField(
                            title: "Password",
                            placeholder: "Enter your password",
                            text: $viewModel.password,
                            isSecure: true
                        )

                        // Remember Me & Forgot Password
                        HStack {
                            Toggle(isOn: $viewModel.rememberMe) {
                                Text("Remember me")
                                    .font(.system(size: 12))
                                    .foregroundColor(.customPlaceholder)
                            }
                            .toggleStyle(CheckboxToggleStyle())

                            Spacer()

                            Button("Forgot Password?") {
                                viewModel.forgotPassword()
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.customBlue)
                        }

                        // Login Button
                        Button(action: {
                            // Do login stuff here and if true switch view to MainContentView
                            if AuthenticationManager.authenticate(email: viewModel.email, password: viewModel.password) {
                                isLoggedIn = true
                            } else {
                                print("Authentication failed")
                            }
                        }) {
                            Text("Log In")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .customButtonStyle()

                        // Divider
                        DividerWithText(text: "Or")
                            .padding(.vertical)

                        // Social Login Buttons
                        VStack(spacing: 16) {
                            SocialLoginButton(
                                title: "Continue with Google",
                                iconName: "google_icon",
                                action: viewModel.loginWithGoogle
                            )

                            SocialLoginButton(
                                title: "Continue with Apple",
                                iconName: "apple_icon",
                                action: viewModel.loginWithApple
                            )
                        }
                    }
                }
                .padding(34)
                .background(Color.white)
                .cornerRadius(24)
                .offset(y: 0)
            }
        }
        .background(Color.customBackground)
        .edgesIgnoringSafeArea(.all)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .customBlue : .gray)
                .font(.system(size: 14))
                .onTapGesture {
                    configuration.isOn.toggle()
                }

            configuration.label
        }
    }
}

#Preview {
    // For preview purposes, provide a constant binding.
    LoginView(isLoggedIn: .constant(false))
}
