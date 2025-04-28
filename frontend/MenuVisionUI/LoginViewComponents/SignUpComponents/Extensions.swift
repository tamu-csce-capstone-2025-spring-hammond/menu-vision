//
//  Extensions.swift
//  MenuVision
//
//  Created by Albert Yin on 3/26/25.
//

import SwiftUI

// MARK: - Color Extensions

/// Extensions to Color providing predefined color values
extension Color {
    /// Slate color with 95% darkness (very dark blue-gray)
    static let slate950 = Color(red: 0.02, green: 0.04, blue: 0.08)
    
    /// Light slate color with 10% darkness
    static let slate100 = Color(red: 0.94, green: 0.95, blue: 0.98)

    /// Very light zinc color (almost white)
    static let zinc100 = Color(red: 0.95, green: 0.95, blue: 0.96)
    
    /// Medium zinc color (middle gray)
    static let zinc500 = Color(red: 0.45, green: 0.45, blue: 0.48)

    /// Very light gray color
    static let gray100 = Color(red: 0.96, green: 0.96, blue: 0.98)
    
    /// Light gray color
    static let gray200 = Color(red: 0.93, green: 0.95, blue: 0.95)
    
    /// Medium gray color
    static let gray500 = Color(red: 0.45, green: 0.45, blue: 0.48)

    /// Medium neutral gray
    static let neutral400 = Color(red: 0.6, green: 0.6, blue: 0.6)

    /// Soft orange color
    static let orange300 = Color(red: 0.99, green: 0.68, blue: 0.38)
}

// MARK: - View Extensions

/// Extensions to View providing additional functionality
extension View {
    /// Apply corner radius to specific corners of a view
    ///
    /// - Parameters:
    ///   - radius: The radius to apply to the specified corners
    ///   - corners: The corners to apply the radius to
    /// - Returns: A view with the specified corner radius applied
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Custom Shapes

/// A shape that applies a corner radius to specific corners of a rectangle
struct RoundedCorner: Shape {
    /// The radius to apply to the specified corners
    var radius: CGFloat = .infinity
    
    /// The corners to apply the radius to
    var corners: UIRectCorner = .allCorners

    /// Creates a path that represents a rounded rectangle with the specified corners
    ///
    /// - Parameter rect: The rectangle to apply the rounded corners to
    /// - Returns: A path that represents the rounded rectangle
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
