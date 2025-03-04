//
//  NewView.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 2/28/25.
//

//
//  NewView.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 2/28/25.
//

import SwiftUI

struct NewView: View {
    var body: some View {
        VStack {
            Text("Welcome to the New View!")
                .font(.largeTitle)
                .padding()

            Text("This view is presented when you tap the new view tab.")
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
        }
        .navigationTitle("New View")
        .padding()
    }
}

struct NewView_Previews: PreviewProvider {
    static var previews: some View {
        NewView()
    }
}
