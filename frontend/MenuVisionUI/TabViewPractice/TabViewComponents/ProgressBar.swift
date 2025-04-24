//
//  ProgressBar.swift
//  MenuVision
//
//  Created by Albert Yin on 4/24/25.
//


import SwiftUI
import WebKit

struct ProgressBar: View {
    var progress: Double

    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 4) {
                GIFView(gifName: "progressLoader")
                    .frame(width: 300, height: 300)
                    .accessibilityLabel("Loading")

                Text("Cooking your food... \(Int(progress * 100))%")
                    .font(.headline)
                    .foregroundColor(.black)
                    .font(.headline)
                    .foregroundColor(.black)
            }
        }
    }
}

struct GIFView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isUserInteractionEnabled = false
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .clear
        webView.isOpaque = false

        if let path = Bundle.main.path(forResource: gifName, ofType: "gif") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            webView.load(data!, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: path))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No update needed
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.white
            ProgressBar(progress: 0.72)
        }
        .frame(width: 150, height: 150)
        .previewLayout(.sizeThatFits)
    }
}
