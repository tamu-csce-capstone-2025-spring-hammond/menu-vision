//
//  ProfileForm.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 2/28/25.
//

import SwiftUI

struct ProfileForm: View {
    @Binding var profileInfo: ProfileInfo

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                AsyncImage(url: URL(string: "https://placehold.co/56x56&format=webp")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .padding(.trailing, 16)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Test Profile")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(.systemGray))

                    Button("+ Add status") {
                        // Add status action
                    }
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "7E49FF"))
                }
            }
            .padding(.bottom, 32)

            VStack(spacing: 24) {
                FormField(title: "Name", placeholder: "Enter your name", text: $profileInfo.name)
                FormField(title: "Email", placeholder: "Enter your email", text: $profileInfo.email)
                FormField(title: "Phone", placeholder: "Enter your phone", text: $profileInfo.phone)
                FormField(title: "Location", placeholder: "Enter your location", text: $profileInfo.location)
            }
        }
        .padding(24)
    }
}

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(.systemGray))

            TextField(placeholder, text: $text)
                .frame(height: 50)
                .padding(.horizontal, 20)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                )
        }
    }
}
