//
//  TestGetUserID.swift
//  MenuVision
//
//  Created by Sam Zhou on 4/8/25.
//
import SwiftUI
import Foundation

struct TestGetUserID: View {
    //    @State private var sz: Float = 1.0
    let userId = UserDefaults.standard.integer(forKey: "user_id")
    var body: some View {
        Text("Current user ID: \(userId)")
    }
    
}

