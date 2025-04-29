//
//  InputField1.swift
//  MenuVision
//
//  Created by Albert Yin on 3/26/25.
//

import SwiftUI

struct InputField1<TrailingContent: View>: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var trailingIcon: (() -> TrailingContent)?

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

struct InputFieldView_Previews: PreviewProvider {
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
