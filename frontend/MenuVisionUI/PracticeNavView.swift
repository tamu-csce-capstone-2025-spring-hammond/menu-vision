//
//  PracticeNavView.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 3/1/25.
//
import SwiftUI

struct PracticeNavView: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: ContentView()) {
                    Text("Hello, World!")
                }
                .navigationTitle("Navigation")
        }
    }
}

#Preview {
    PracticeNavView()
}
