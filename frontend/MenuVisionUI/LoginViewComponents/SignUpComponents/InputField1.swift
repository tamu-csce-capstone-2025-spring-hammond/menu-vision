//
//  InputField1.swift
//  MenuVision
//
//  Created by Albert Yin on 3/26/25.
//

import SwiftUI

/// A customizable input field component with optional trailing icon
///
/// This component provides a styled text field with title, placeholder, and optional trailing icon.
/// It supports both regular and secure text fields.
///
/// Example usage:
/// ```
/// @State private var email = ""
///
/// InputField1(
///     title: "Email",
///     placeholder: "Enter your email",
///     text: $email
/// )
/// ```
struct InputField1<TrailingContent: View>: View {
    /// The title displayed above the text field
    let title: String
    
    /// Placeholder text shown when the field is empty
    let placeholder: String
    
    /// Binding to the input text value
    @Binding var text: String
    
    /// Whether this is a secure text field (password field)
    var isSecure: Bool = false
    
    /// Optional trailing icon to display inside the field
    var trailingIcon: (() -> TrailingContent)?

    /// Initializes an InputField1 with optional trailing icon
    ///
    /// - Parameters:
    ///   - title: The title displayed above the text field
    ///   - placeholder: Placeholder text shown when the field is empty
    ///   - text: Binding to the input text value
    ///   - isSecure: Whether this is a secure text field (password field)
    ///   - trailingIcon: Optional trailing icon to display inside the field
    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        @ViewBuilder trailingIcon: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.trailingIcon = trailingIcon
    }

    /// The body of the input field view
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .tracking(-0.3)
                .foregroundColor(Color.zinc500)

            HStack {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 14))
                        .foregroundColor(Color.black)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 14))
                        .foregroundColor(Color.black)
                }

                if let trailingIcon = trailingIcon {
                    trailingIcon()
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray200, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        }
    }
}

/// Preview provider for InputField1
struct InputFieldView_Previews: PreviewProvider {
    /// Generate previews showing different configurations
    static var previews: some View {
        VStack {
            InputField1(
                title: "Email",
                placeholder: "email",
                text: .constant("")
            )

            InputField1(
                title: "Password",
                placeholder: "password",
                text: .constant(""),
                isSecure: true,
                trailingIcon: {
                    Image(systemName: "eye")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color.gray)
                }
            )
        }
        .padding()
        .background(Color.white)
        .previewLayout(.sizeThatFits)
    }
}
