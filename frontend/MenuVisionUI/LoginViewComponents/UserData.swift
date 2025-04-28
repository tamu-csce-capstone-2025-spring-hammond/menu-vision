//
//  UserData.swift
//  MenuVision
//
//  Created by Sam Zhou on 4/16/25.
//

import Foundation

/// A class that stores and manages user data in the application.
///
/// This class maintains all user-related information such as personal details,
/// preferences, and restrictions, and provides methods to reset this data.
class UserData: ObservableObject {
    /// The unique identifier for the user.
    @Published var user_id: Int = 0
    
    /// The user's first name.
    @Published var first_name: String = ""
    
    /// The user's last name.
    @Published var last_name: String = ""
    
    /// The user's email address.
    @Published var email: String = ""
    
    /// The user's age.
    @Published var age: Int = 0
    
    /// The user's dietary restrictions.
    @Published var food_restrictions: [String] = []
    
    /// The user's food preferences, typically cuisine types.
    @Published var food_preferences: [String] = []
    
    /// The user's accumulated points in the system.
    @Published var total_points: Int = 0
    
    /// Resets all user data to default values.
    ///
    /// This method is typically called during logout or when clearing user data.
    func resetData() {
        user_id = 0
        first_name = ""
        last_name = ""
        email = ""
        age = 0
        food_restrictions = []
        food_preferences = []
        total_points = 0
    }
    
}
