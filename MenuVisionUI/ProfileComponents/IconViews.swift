//
//  IconViews.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 2/28/25.
//

import SwiftUI

struct BackIcon: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 15, y: 18))
            path.addLine(to: CGPoint(x: 9, y: 12))
            path.addLine(to: CGPoint(x: 15, y: 6))
        }
        .stroke(Color(.systemGray), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .frame(width: 24, height: 24)
    }
}

struct HomeIcon: View {
    var isSelected: Bool

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 12, y: 3))
            path.addLine(to: CGPoint(x: 5, y: 10))
            path.addLine(to: CGPoint(x: 3, y: 12))
            path.move(to: CGPoint(x: 5, y: 10))
            path.addLine(to: CGPoint(x: 19, y: 10))
            path.addLine(to: CGPoint(x: 21, y: 12))
            path.move(to: CGPoint(x: 19, y: 10))
            path.addLine(to: CGPoint(x: 19, y: 20))
            path.addLine(to: CGPoint(x: 15, y: 21))
            path.move(to: CGPoint(x: 5, y: 10))
            path.addLine(to: CGPoint(x: 5, y: 20))
            path.addLine(to: CGPoint(x: 9, y: 21))
        }
        .stroke(isSelected ? Color.white : Color(.systemGray), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .frame(width: 24, height: 24)
    }
}

struct ProfileIcon: View {
    var isSelected: Bool

    var body: some View {
        Path { path in
            // Head
            path.addArc(center: CGPoint(x: 12, y: 7), radius: 4, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
            // Body
            path.move(to: CGPoint(x: 5, y: 21))
            path.addLine(to: CGPoint(x: 19, y: 21))
            path.addCurve(to: CGPoint(x: 12, y: 14),
                         control1: CGPoint(x: 19, y: 17),
                         control2: CGPoint(x: 15.5, y: 14))
            path.addCurve(to: CGPoint(x: 5, y: 21),
                         control1: CGPoint(x: 8.5, y: 14),
                         control2: CGPoint(x: 5, y: 17))
        }
        .stroke(isSelected ? Color.white : Color(.systemGray), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .frame(width: 24, height: 24)
    }
}

struct AddIcon: View {
    var isSelected: Bool

    var body: some View {
        Path { path in
            path.addEllipse(in: CGRect(x: 3, y: 3, width: 18, height: 18))
            path.move(to: CGPoint(x: 12, y: 9))
            path.addLine(to: CGPoint(x: 12, y: 15))
            path.move(to: CGPoint(x: 9, y: 12))
            path.addLine(to: CGPoint(x: 15, y: 12))
        }
        .stroke(isSelected ? Color.white : Color(.systemGray), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .frame(width: 24, height: 24)
    }
}

struct StatsIcon: View {
    var isSelected: Bool

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 12, y: 3))
            path.addArc(center: CGPoint(x: 12, y: 12), radius: 9, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            path.addLine(to: CGPoint(x: 12, y: 12))
            path.addLine(to: CGPoint(x: 12, y: 3))
        }
        .stroke(isSelected ? Color.white : Color(.systemGray), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .frame(width: 24, height: 24)
    }
}

struct SettingsIcon: View {
    var isSelected: Bool

    var body: some View {
        Path { path in
            path.addEllipse(in: CGRect(x: 9, y: 9, width: 6, height: 6))
        }
        .stroke(isSelected ? Color.white : Color(.systemGray), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .frame(width: 24, height: 24)
    }
}
