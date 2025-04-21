//
//  UserStateViewModel.swift
//  MenuVision
//
//  Created by Sam Zhou on 4/12/25.
//

import Foundation

@MainActor
class UserStateViewModel: ObservableObject {
    
    @Published var isLoggedIn = false
    @Published var isBusy = false
    
    // Add a reference to UserData
    @Published var userData: UserData = UserData()

    
    // Method to set userData instance
    func setUserData(_ userData: UserData) {
        self.userData = userData
    }
    
    // Method to load user data when logged in
    func loadUserDataIfLoggedIn() {
        print("isLoggedIn", isLoggedIn)
//        guard isLoggedIn, let userData = userData else { return }
        
        let userId = UserDefaults.standard.integer(forKey: "user_id")
        if userId != 0 {
            isBusy = true
            print("userId", userId)
            self.loadUserData(userId: userId) { [weak self] success in
                self?.isBusy = false
                if !success {
                    print("Failed to load user data")
                    // Optionally handle failure
                }
            }
        }
    }
    
    // Observer for isLoggedIn changes
    func didChangeLoginState() {
        if isLoggedIn {
            loadUserDataIfLoggedIn()
            print("email",self.userData.email)
//            print(self.userData?.$email)
        } else {
            // Clear user data if logged out
            userData.resetData()
        }
    }
    
    func loadUserData(userId: Int, completion: @escaping (Bool) -> Void) {
        print("called")
        API.shared.request(
            endpoint: "user/\(userId)",
            method: "GET"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            print(json)
                            
                            // Safely unwrap all values with nil coalescing
                            if let userId = json["user_id"] as? Int {
                                self.userData.user_id = userId
                                print(self.userData.user_id)
                            }
                            
                            self.userData.first_name = json["first_name"] as? String ?? ""
                            self.userData.last_name = json["last_name"] as? String ?? ""
                            self.userData.email = json["email"] as? String ?? ""
                            print(self.userData.email)
                            
                            self.userData.age = json["age"] as? Int ?? 0
                            self.userData.food_restrictions = json["food_restrictions"] as? [String] ?? []
                            self.userData.food_preferences = json["food_preferences"] as? [String] ?? []
                            self.userData.total_points = json["total_points"] as? Int ?? 0
                            
                            completion(true)
                        } else {
                            print("Failed to parse JSON")
                            completion(false)
                        }
                    } catch {
                        print("JSON parsing error: \(error)")
                        completion(false)
                    }
                case .failure(let error):
                    print("API error: \(error)")
                    completion(false)
                }
            }
        }
    }
}
