import Foundation

struct AuthenticationManager {
    /// Validates the provided email and password.
    /// - Returns: `true` if the credentials are valid; otherwise, `false`.
    static func authenticate(email: String, password: String) -> Bool {
        // Replace this with your actual authentication logic (e.g., API call).
        return email == "User" && password == "password"
    }
}
