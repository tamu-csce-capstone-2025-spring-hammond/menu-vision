//
//  ThirdTabView.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 3/1/25.
//
import SwiftUI

struct ThirdTabView: View {
    var body: some View {
        VStack {
            Text("Settings Screen")
                .font(.largeTitle)
                .padding()
            Image(systemName: "gearshape.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
    }
}
