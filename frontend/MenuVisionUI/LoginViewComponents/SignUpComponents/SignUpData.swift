//
//  SignUpData.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 3/27/25.
//

import Foundation

/// A class for managing sign-up form data
///
/// This observable object provides properties for storing and managing
/// all the data collected during the user signup process, including
/// dietary restrictions, cuisine preferences, personal information,
/// and authentication credentials.
///
/// Example usage:
/// ```
/// let signUpData = SignUpData()
/// signUpData.first_name = "John"
/// signUpData.email = "john@example.com"
/// ```
class SignUpData: ObservableObject {
    /// Set of dietary restriction selections
    @Published var dietaryRestrictions: Set<String> = []
    
    /// Set of preferred cuisine types
    @Published var selectedCuisines: Set<String> = []
    
    /// User's first name
    @Published var first_name: String = ""
    
    /// User's last name
    @Published var last_name: String = ""
    
    /// User's age
    @Published var age: String = ""
    
    /// User's chosen username
    @Published var username: String = ""
    
    /// User's email address
    @Published var email: String = ""
    
    /// User's password (temporarily stored during signup process)
    @Published var password: String = ""
}
