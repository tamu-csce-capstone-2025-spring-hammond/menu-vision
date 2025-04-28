//
//  PasswordField.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/24/25.
//

import SwiftUI

/// A custom password input field with visibility toggle
///
/// This component provides a styled password field with optional title,
/// placeholder text, and a visibility toggle button that allows users to
/// see the password they've entered.
///
/// Example usage:
/// ```
/// @State private var password = ""
///
/// PasswordField(
///     title: "Password",
///     password: $password,
///     placeholder: "Enter your password"
/// )
/// ```
struct PasswordField: View {
    /// The title displayed above the password field (can be empty)
    let title: String
    
    /// Binding to the password text value
    @Binding var password: String
    
    /// Placeholder text shown when the field is empty
    let placeholder: String
    
    /// Whether the password is currently visible or masked
    @State private var isSecured: Bool = true

    /// State to track if the field is currently focused
    @FocusState private var isFocused: Bool

    /// The body of the password field view
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

/// Preview provider for PasswordField
struct PasswordField_Previews: PreviewProvider {
    /// State variable for preview
    @State static var password = ""

    /// Generate previews showing different configurations
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
