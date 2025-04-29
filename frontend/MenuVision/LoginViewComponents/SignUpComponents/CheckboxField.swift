//
//  CheckboxField.swift
//  MenuVisionUI
//
//  Created by Albert Yin on 3/24/25.
//

import SwiftUI

struct CheckboxField: View {
    @Binding var isChecked: Bool
    let text: String

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

    // Format the text to support styling for terms and privacy policy
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

extension Text {
    init(verbatim content: LocalizedStringKey) {
        self.init(content)
    }
}

struct CheckboxField_Previews: PreviewProvider {
    @State static var isChecked = false

    static var previews: some View {
        CheckboxField(
            isChecked: $isChecked,
            text: "I've read and agree with the Terms and Conditions and the Privacy Policy."
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
