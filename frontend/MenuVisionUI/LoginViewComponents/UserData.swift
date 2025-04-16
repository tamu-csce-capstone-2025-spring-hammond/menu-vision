//
//  UserData.swift
//  MenuVision
//
//  Created by Sam Zhou on 4/16/25.
//

import Foundation

class UserData: ObservableObject {
    @Published var user_id: Int = 0
    @Published var first_name: String = ""
    @Published var last_name: String = ""
    @Published var email: String = ""
    @Published var age: Int = 0
    @Published var food_restrictions: [String] = []
    @Published var food_preferences: [String] = []
    @Published var total_points: Int = 0
    
    // Add this to the UserData class
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
