import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = false
    @Published var isLoginMode: Bool = true
    
    // Callback to notify that login was successful.
    var onLoginSuccess: () -> Void = {}

    func login() {
        print("Login attempted with email: \(email)")
        if AuthenticationManager.authenticate(email: email, password: password) {
            // Trigger the navigation callback on successful authentication.
            onLoginSuccess()
            print("login success")
        } else {
            // Optionally, update a published property to show an error message.
            print("Authentication failed")
        }
    }

    func loginWithGoogle() {
        print("Google login attempted")
    }

    func loginWithApple() {
        print("Apple login attempted")
    }

    func forgotPassword() {
        print("Forgot password requested")
    }
}
