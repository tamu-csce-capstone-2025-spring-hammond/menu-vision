//
//  CustomTextField.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 2/26/25.
//

import SwiftUI

struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.customPlaceholder)

            if isSecure {
                HStack {
                    if isPasswordVisible {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }

                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                .customTextFieldStyle()
            } else {
                TextField(placeholder, text: $text)
                    .customTextFieldStyle()
            }
        }
    }
}
