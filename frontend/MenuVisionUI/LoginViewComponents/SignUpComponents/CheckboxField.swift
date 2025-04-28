//
//  CheckboxField.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/24/25.
//

import SwiftUI

/// A customizable checkbox field with accompanying text
///
/// This view provides a checkbox control with associated text label. The text can include
/// specially formatted sections like "Terms and Conditions" and "Privacy Policy" which will
/// be displayed in bold.
///
/// Example usage:
/// ```
/// @State private var isChecked = false
///
/// CheckboxField(
///     isChecked: $isChecked,
///     text: "I've read and agree with the Terms and Conditions and the Privacy Policy."
/// )
/// ```
struct CheckboxField: View {
    /// Binding to a boolean that determines if the checkbox is checked
    @Binding var isChecked: Bool
    
    /// The text to display next to the checkbox
    ///
    /// Special keywords "Terms and Conditions" and "Privacy Policy" will be formatted in bold
    let text: String

    /// The body of the checkbox field view
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: {
                isChecked.toggle()
            }) {
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(UIColor.systemGray4), lineWidth: 1.5)
                        )

                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.orange.opacity(0.6))
                    }
                }
            }

            Text(LocalizedStringKey(formattedText))
                .font(.system(size: 12))
                .foregroundColor(Color(UIColor.systemGray))
        }
    }

    /// Formats the text to support styling for terms and privacy policy
    ///
    /// This computed property replaces the terms and privacy policy text with markdown-style
    /// bold markers to enable special formatting when displayed.
    private var formattedText: String {
        // Replace the terms and privacy policy with markdown-style bold markers
        let withTerms = text.replacingOccurrences(
            of: "Terms and Conditions",
            with: "**Terms and Conditions**"
        )

        let withBoth = withTerms.replacingOccurrences(
            of: "Privacy Policy",
            with: "**Privacy Policy**"
        )

        return withBoth
    }
}

/// Extension to support LocalizedStringKey in Text initialization
extension Text {
    /// Initializes a Text view with the specified verbatim content
    /// - Parameter content: The localized string key content to display
    init(verbatim content: LocalizedStringKey) {
        self.init(content)
    }
}

/// A preview provider for the CheckboxField view
struct CheckboxField_Previews: PreviewProvider {
    /// State variable for preview
    @State static var isChecked = false

    /// Generates a preview of the CheckboxField
    static var previews: some View {
        CheckboxField(
            isChecked: $isChecked,
            text: "I've read and agree with the Terms and Conditions and the Privacy Policy."
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
