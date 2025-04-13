//
//  UserStateViewModel.swift
//  MenuVision
//
//  Created by Sam Zhou on 4/12/25.
//

import Foundation

enum UserStateError: Error{
    case signInError, signOutError
}

@MainActor
class UserStateViewModel: ObservableObject {
    
    @Published var isLoggedIn = false
    @Published var isBusy = false
    
}
