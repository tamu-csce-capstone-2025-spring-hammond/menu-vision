//
//  FontRegistration.swift
//  MenuVision
//
//  Created by Albert Yin on 4/10/25.
//

import SwiftUI
import CoreText

// This helper handles font registration for custom fonts
class FontRegistration {
    static func registerFonts() {
        // Register Inter font family
        registerFont(name: "Inter-Regular", withExtension: "ttf")
        registerFont(name: "Inter-Bold", withExtension: "ttf")
        registerFont(name: "Inter-SemiBold", withExtension: "ttf")
        registerFont(name: "Inter-Italic", withExtension: "ttf")

        // Register Maven Pro font family
        registerFont(name: "MavenPro-ExtraBold", withExtension: "ttf")
    }

    private static func registerFont(name: String, withExtension: String) {
        guard let fontURL = Bundle.main.url(forResource: name, withExtension: withExtension),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            print("Failed to load font: \(name).\(withExtension)")
            return
        }

        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            if let error = error?.takeRetainedValue() {
                let errorDescription = CFErrorCopyDescription(error)
                print("Failed to register font: \(errorDescription)")
            }
        }
    }
}

// SwiftUI modifier to load fonts
struct FontLoader: ViewModifier {
    init() {
        FontRegistration.registerFonts()
    }

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func loadCustomFonts() -> some View {
        self.modifier(FontLoader())
    }
}
