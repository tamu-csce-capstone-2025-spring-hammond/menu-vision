//
//  InputField.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/24/25.
//

import SwiftUI

/// A custom text input field with title and placeholder
///
/// This component provides a styled text field with an optional title label and
/// customizable placeholder text. It also supports different keyboard types.
///
/// Example usage:
/// ```
/// @State private var name = ""
///
/// InputField(
///     title: "Name",
///     text: $name,
///     placeholder: "Enter your name"
/// )
/// ```
struct InputField: View {
    /// The title displayed above the text field
    let title: String
    
    /// Binding to the input text value
    @Binding var text: String
    
    /// Placeholder text shown when the field is empty
    let placeholder: String
    
    /// The keyboard type to use for the input field
    var keyboardType: UIKeyboardType = .default

    /// State to track if the field is currently focused
    @FocusState private var isFocused: Bool

    /// The body of the input field view
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(UIColor.darkGray))
            }

            ZStack(alignment: .leading) {
                // This is the actual input field
                TextField("", text: $text)
                    .focused($isFocused)
                    .font(.system(size: 14))
                    .foregroundColor(Color(UIColor.darkGray))
                    .keyboardType(keyboardType)
                    .autocapitalization(.none) // For compatibility
                    .textInputAutocapitalization(.never) // Preferred in iOS 15+

                // This is the placeholder that only shows when text is empty
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 14).italic())
                        .foregroundColor(Color(UIColor.systemGray))
                        .allowsHitTesting(false) // Make sure this doesn't interfere with TextField interaction
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

/// Preview provider for InputField
struct InputField_Previews: PreviewProvider {
    /// State variable for preview
    @State static var text = ""

    /// Generate previews showing different configurations
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
