//
//  Extensions.swift
//  MenuVision
//
//  Created by Albert Yin on 3/26/25.
//

import SwiftUI

// MARK: - Color Extensions
extension Color {
    // Slate colors
    static let slate950 = Color(red: 0.02, green: 0.04, blue: 0.08)
    static let slate100 = Color(red: 0.94, green: 0.95, blue: 0.98)

    // Zinc colors
    static let zinc100 = Color(red: 0.95, green: 0.95, blue: 0.96)
    static let zinc500 = Color(red: 0.45, green: 0.45, blue: 0.48)

    // Gray colors
    static let gray100 = Color(red: 0.96, green: 0.96, blue: 0.98)
    static let gray200 = Color(red: 0.93, green: 0.95, blue: 0.95)
    static let gray500 = Color(red: 0.45, green: 0.45, blue: 0.48)

    // Neutral colors
    static let neutral400 = Color(red: 0.6, green: 0.6, blue: 0.6)

    // Orange colors
    static let orange300 = Color(red: 0.99, green: 0.68, blue: 0.38)
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Custom Shapes
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
