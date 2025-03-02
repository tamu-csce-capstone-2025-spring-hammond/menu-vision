//
//  FirstTabView.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 3/1/25.
//
import SwiftUI


struct FirstTabView: View {
    var body: some View {
        VStack {
            Text("Home Screen")
                .font(.largeTitle)
                .padding()
            Image(systemName: "house.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
    }
}
