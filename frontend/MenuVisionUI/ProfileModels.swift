//
//  ProfileModels.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 2/28/25.
//

import Foundation

struct ProfileInfo {
    var name: String = ""
    var email: String = ""
    var phone: String = ""
    var location: String = ""
}

enum TabItem: String {
    case home
    case profile
    case add
    case stats
    case settings
}
