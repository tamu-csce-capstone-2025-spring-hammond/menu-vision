//
//  InputField.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/24/25.
//

import SwiftUI

struct InputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(UIColor.darkGray))
            }

            TextField(placeholder, text: $text)
                .focused($isFocused)
                .font(.system(size: 14))
                .foregroundColor(text.isEmpty ? Color(UIColor.systemGray) : Color(UIColor.darkGray))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(height: 48)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFocused ? Color.blue.opacity(0.8) : Color(UIColor.systemGray4), lineWidth: isFocused ? 1.5 : 1)
                )
                .keyboardType(keyboardType)
        }
    }
}

struct InputField_Previews: PreviewProvider {
    @State static var text = ""

    static var previews: some View {
        VStack {
            InputField(
                title: "Name",
                text: $text,
                placeholder: "Enter your name"
            )

            InputField(
                title: "Email",
                text: $text,
                placeholder: "Enter your email",
                keyboardType: .emailAddress
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
