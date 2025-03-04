//
//  DividerWithText.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 2/26/25.
//

import SwiftUI

struct DividerWithText: View {
    let text: String

    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.customBorder)
                .frame(height: 1)

            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.customPlaceholder)

            Rectangle()
                .fill(Color.customBorder)
                .frame(height: 1)
        }
        .padding(.horizontal)
    }
}
