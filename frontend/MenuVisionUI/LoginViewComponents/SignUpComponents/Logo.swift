//
//  Logo.swift
//  MenuVision
//
//  Created by Albert Yin on 3/26/25.
//

import SwiftUI

struct Logo: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height

        // Scale factors to maintain proportions
        let scaleX = width / 240
        let scaleY = height / 230

        var path = Path()

        // First path from the SVG
        path.move(to: CGPoint(x: 120 * scaleX, y: 230 * scaleY))
        path.addCurve(
            to: CGPoint(x: 240 * scaleX, y: 115 * scaleY),
            control1: CGPoint(x: 186.276 * scaleX, y: 230 * scaleY),
            control2: CGPoint(x: 240 * scaleX, y: 178.514 * scaleY)
        )
        path.addLine(to: CGPoint(x: 240 * scaleX, y: 34.5 * scaleY))
        path.addCurve(
            to: CGPoint(x: 204 * scaleX, y: 0 * scaleY),
            control1: CGPoint(x: 240 * scaleX, y: 25.35 * scaleY),
            control2: CGPoint(x: 222.705 * scaleX, y: 3.63481 * scaleY)
        )
        path.addLine(to: CGPoint(x: 126 * scaleX, y: 0 * scaleY))
        path.addLine(to: CGPoint(x: 126 * scaleX, y: 50.4505 * scaleY))
        path.addCurve(
            to: CGPoint(x: 133.032 * scaleX, y: 83.6855 * scaleY),
            control1: CGPoint(x: 126 * scaleX, y: 61.962 * scaleY),
            control2: CGPoint(x: 126.732 * scaleX, y: 73.8875 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 174.456 * scaleX, y: 110.291 * scaleY),
            control1: CGPoint(x: 137.542 * scaleX, y: 90.7074 * scaleY),
            control2: CGPoint(x: 157.87 * scaleX, y: 105.899 * scaleY)
        )
        path.addLine(to: CGPoint(x: 176.754 * scaleX, y: 110.647 * scaleY))
        path.addCurve(
            to: CGPoint(x: 180.002 * scaleX, y: 115 * scaleY),
            control1: CGPoint(x: 177.701 * scaleX, y: 110.958 * scaleY),
            control2: CGPoint(x: 180.002 * scaleX, y: 114.041 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 176.754 * scaleX, y: 119.353 * scaleY),
            control1: CGPoint(x: 180.002 * scaleX, y: 115.959 * scaleY),
            control2: CGPoint(x: 177.701 * scaleX, y: 119.042 * scaleY)
        )
        path.addLine(to: CGPoint(x: 174.456 * scaleX, y: 119.709 * scaleY))
        path.addCurve(
            to: CGPoint(x: 124.914 * scaleX, y: 167.187 * scaleY),
            control1: CGPoint(x: 162.049 * scaleX, y: 121.652 * scaleY),
            control2: CGPoint(x: 132.814 * scaleX, y: 144.317 * scaleY)
        )
        path.addLine(to: CGPoint(x: 124.542 * scaleX, y: 169.389 * scaleY))
        path.addCurve(
            to: CGPoint(x: 120 * scaleX, y: 172.501 * scaleY),
            control1: CGPoint(x: 124.218 * scaleX, y: 170.297 * scaleY),
            control2: CGPoint(x: 121.977 * scaleX, y: 172.201 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 115.458 * scaleX, y: 169.389 * scaleY),
            control1: CGPoint(x: 118.999 * scaleX, y: 172.501 * scaleY),
            control2: CGPoint(x: 116.394 * scaleX, y: 171.085 * scaleY)
        )
        path.addLine(to: CGPoint(x: 115.086 * scaleX, y: 167.187 * scaleY))
        path.addCurve(
            to: CGPoint(x: 87.3242 * scaleX, y: 127.489 * scaleY),
            control1: CGPoint(x: 113.699 * scaleX, y: 159.049 * scaleY),
            control2: CGPoint(x: 100.922 * scaleX, y: 137.594 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 52.6442 * scaleX, y: 120.75 * scaleY),
            control1: CGPoint(x: 77.1002 * scaleX, y: 121.451 * scaleY),
            control2: CGPoint(x: 64.6562 * scaleX, y: 120.75 * scaleY)
        )
        path.addLine(to: CGPoint(x: 0.144287 * scaleX, y: 120.75 * scaleY))
        path.addCurve(
            to: CGPoint(x: 120 * scaleX, y: 230 * scaleY),
            control1: CGPoint(x: 3.28228 * scaleX, y: 181.591 * scaleY),
            control2: CGPoint(x: 55.7402 * scaleX, y: 230 * scaleY)
        )

        // Second path from the SVG
        path.move(to: CGPoint(x: 0 * scaleX, y: 109.251 * scaleY))
        path.addLine(to: CGPoint(x: 52.6439 * scaleX, y: 109.251 * scaleY))
        path.addCurve(
            to: CGPoint(x: 87.3239 * scaleX, y: 102.512 * scaleY),
            control1: CGPoint(x: 64.6559 * scaleX, y: 109.251 * scaleY),
            control2: CGPoint(x: 77.0999 * scaleX, y: 108.549 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 106.968 * scaleX, y: 83.6862 * scaleY),
            control1: CGPoint(x: 95.316 * scaleX, y: 97.7926 * scaleY),
            control2: CGPoint(x: 102.044 * scaleX, y: 91.3453 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 114 * scaleX, y: 50.4512 * scaleY),
            control1: CGPoint(x: 113.268 * scaleX, y: 73.8882 * scaleY),
            control2: CGPoint(x: 114 * scaleX, y: 61.9627 * scaleY)
        )
        path.addLine(to: CGPoint(x: 114 * scaleX, y: 0.000694955 * scaleY))
        path.addLine(to: CGPoint(x: 36 * scaleX, y: 0.000694955 * scaleY))
        path.addCurve(
            to: CGPoint(x: 0 * scaleX, y: 34.5007 * scaleY),
            control1: CGPoint(x: 26.4522 * scaleX, y: 0.000694955 * scaleY),
            control2: CGPoint(x: 3.79284 * scaleX, y: 16.5755 * scaleY)
        )
        path.addLine(to: CGPoint(x: 0 * scaleX, y: 109.251 * scaleY))

        return path
    }
}

// Color extension with init(hex:) is already defined elsewhere in the project

struct CustomLogo: View {
    var size: CGSize
    var color: Color

    init(width: CGFloat = 18, height: CGFloat = 18, color: Color = Color(hex: "FAAC7B")) {
        self.size = CGSize(width: width, height: height)
        self.color = color
    }

    var body: some View {
        Logo()
            .fill(color)
            .frame(width: size.width, height: size.height)
    }
}
