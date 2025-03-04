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
                .foregroundColor(.black) // Label text is now black

            if isSecure {
                HStack {
                    if isPasswordVisible {
                        TextField(placeholder, text: $text)
                            .foregroundColor(.black) // Text input color is black
                    } else {
                        SecureField(placeholder, text: $text)
                            .foregroundColor(.black) // Secure input text color is black
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
                    .foregroundColor(.black) // Text input color is black
                    .customTextFieldStyle()
            }
        }
    }
}
