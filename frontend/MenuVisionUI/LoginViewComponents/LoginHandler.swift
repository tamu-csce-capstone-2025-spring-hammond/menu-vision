//
//  LoginHandler.swift
//  MenuVision
//
//  Created by Sam Zhou on 4/9/25.
//

import Foundation

/// A singleton class that handles user authentication operations for the MenuVision app.
///
/// LoginHandler provides methods for validating user credentials, fetching AWS credentials
/// after successful login, and retrieving stored AWS credentials from UserDefaults.
class LoginHandler {
    /// The shared singleton instance of the LoginHandler.
    static let shared = LoginHandler()
    
    /// Private initializer to ensure singleton pattern.
    private init() {}
    
    /// Validates user login credentials against the backend API.
    ///
    /// This method sends the user's email and password to the authentication endpoint,
    /// processes the response, and handles storing user ID in UserDefaults if "remember me" is enabled.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - rememberMe: Boolean indicating if the user's login should be persisted.
    ///   - completion: A closure that receives login success status, optional error message, and optional user ID.
    ///                 Called on the main thread when authentication completes.
    func validateLogin(email: String, password: String, rememberMe: Bool, completion: @escaping (Bool, String?, Int?) -> Void) {
        let payload = [
            "email": email,
            "password": password
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(false, "Failed to encode credentials.", nil)
            return
        }

        API.shared.request(
            endpoint: "user/login",
            method: "POST",
            body: jsonData,
            headers: ["Content-Type": "application/json"]
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let message = response["message"] as? String, message == "Login successful" {
                            if let userId = response["user_id"] as? Int {
                                // Store user ID if remember me is checked
                                if rememberMe {
                                    
                                    UserDefaults.standard.set(userId, forKey: "user_id")
                                    UserDefaults.standard.set(true, forKey: "is_logged_in")
                                    
                                    
                                    
                                }
                                
                                // Fetch AWS credentials after successful login
                                self.fetchAWSCredentials()
                                
                                // Return success with userId
                                completion(true, nil, userId)
                            } else {
                                // Return success but without userId
                                completion(true, nil, nil)
                            }
                        } else {
                            let errorMessage = response["message"] as? String ?? "Login failed"
                            completion(false, errorMessage, nil)
                        }
                    } else {
                        completion(false, "Invalid response format", nil)
                    }

                case .failure(let error):
                    completion(false, "Request failed: \(error.localizedDescription)", nil)
                }
            }
        }
    }
    
    /// Fetches AWS credentials from the backend and stores them in UserDefaults.
    ///
    /// Called automatically after successful login to ensure the app has access to
    /// required AWS credentials for S3 operations.
    func fetchAWSCredentials() {
        API.shared.request(
            endpoint: "general/keys",
            method: "GET"
        ) { result in
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: String],
                       let accessKey = json["AWS_ACCESS_KEY"],
                       let secretKey = json["AWS_SECRET_KEY"] {
                        // Store AWS credentials in UserDefaults
                        UserDefaults.standard.set(accessKey, forKey: "AWS_ACCESS_KEY")
                        UserDefaults.standard.set(secretKey, forKey: "AWS_SECRET_KEY")
                        print("AWS credentials stored successfully")
                    } else {
                        print("Error: Invalid AWS credentials format")
                    }
                } catch {
                    print("Error parsing AWS credentials: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("Failed to fetch AWS credentials: \(error.localizedDescription)")
            }
        }
    }
    
    /// Retrieves AWS credentials previously stored in UserDefaults.
    ///
    /// This helper method provides a convenient way to access the AWS access key and secret key
    /// as a tuple, ensuring both values are available.
    ///
    /// - Returns: A tuple containing the access key and secret key, or nil if either is missing.
    func getAWSCredentials() -> (accessKey: String, secretKey: String)? {
        guard let accessKey = UserDefaults.standard.string(forKey: "AWS_ACCESS_KEY"),
              let secretKey = UserDefaults.standard.string(forKey: "AWS_SECRET_KEY") else {
            return nil
        }
        
        return (accessKey, secretKey)
    }
}
