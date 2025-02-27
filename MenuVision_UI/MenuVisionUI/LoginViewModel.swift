//
//  LoginViewModel.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 2/26/25.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = false
    @Published var isLoginMode: Bool = true

    func login() {
        // Implement login logic
        print("Login attempted with email: \(email)")
    }

    func loginWithGoogle() {
        // Implement Google login
        print("Google login attempted")
    }

    func loginWithApple() {
        // Implement Apple login
        print("Apple login attempted")
    }

    func forgotPassword() {
        // Implement forgot password
        print("Forgot password requested")
    }
}
