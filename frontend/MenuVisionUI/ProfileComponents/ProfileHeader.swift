//
//  ProfileHeader.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 2/28/25.
//

import SwiftUI

struct ProfileHeader: View {
    var onBackTapped: () -> Void

    var body: some View {
        HStack {
            Button(action: onBackTapped) {
                BackIcon()
            }
            .padding(.trailing, 20)

            Text("Profile")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(.systemGray))
        }
        .padding(24)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.black.opacity(0.1)),
            alignment: .bottom
        )
        .frame(maxWidth: .infinity, alignment: .leading)

    }
}
