//
//  PasswordField.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/24/25.
//

import SwiftUI

struct PasswordField: View {
    let title: String
    @Binding var password: String
    let placeholder: String
    @State private var isSecured: Bool = true

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(UIColor.darkGray))
            }

            ZStack(alignment: .leading) {
                HStack {
                    if isSecured {
                        // Secure field without placeholder
                        SecureField("", text: $password)
                            .focused($isFocused)
                            .font(.system(size: 14))
                            .foregroundColor(Color(UIColor.darkGray))
                    } else {
                        // Regular text field without placeholder
                        TextField("", text: $password)
                            .focused($isFocused)
                            .font(.system(size: 14))
                            .foregroundColor(Color(UIColor.darkGray))
                    }

                    Button(action: {
                        isSecured.toggle()
                    }) {
                        Image(systemName: isSecured ? "eye.slash" : "eye")
                            .foregroundColor(Color(UIColor.systemGray))
                            .frame(width: 16, height: 16)
                    }
                }

                // Placeholder text that only shows when password is empty
                if password.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 14).italic())
                        .foregroundColor(Color(UIColor.systemGray))
                        .padding(.leading, 0)
                        .allowsHitTesting(false) // Make sure this doesn't interfere with field interaction
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(height: 48)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.blue.opacity(0.8) : Color(UIColor.systemGray4), lineWidth: isFocused ? 1.5 : 1)
            )
        }
    }
}

struct PasswordField_Previews: PreviewProvider {
    @State static var password = ""

    static var previews: some View {
        VStack {
            PasswordField(
                title: "Password",
                password: $password,
                placeholder: "Enter your password"
            )

            PasswordField(
                title: "",
                password: $password,
                placeholder: "Confirm password"
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
