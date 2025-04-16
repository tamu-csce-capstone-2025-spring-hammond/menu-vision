//
//  LoginHandler.swift
//  MenuVision
//
//  Created by Sam Zhou on 4/9/25.
//

import Foundation

class LoginHandler {
    static let shared = LoginHandler()
    
    private init() {}
    
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
    
    // Helper function to get AWS credentials from UserDefaults
    func getAWSCredentials() -> (accessKey: String, secretKey: String)? {
        guard let accessKey = UserDefaults.standard.string(forKey: "AWS_ACCESS_KEY"),
              let secretKey = UserDefaults.standard.string(forKey: "AWS_SECRET_KEY") else {
            return nil
        }
        
        return (accessKey, secretKey)
    }
}
