//
//  SignUpData.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 3/27/25.
//

import Foundation

class SignUpData: ObservableObject {
    @Published var dietaryRestrictions: Set<String> = []
    @Published var selectedCuisines: Set<String> = []
    @Published var first_name: String = ""
    @Published var last_name: String = ""
    @Published var age: String = ""
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
}
