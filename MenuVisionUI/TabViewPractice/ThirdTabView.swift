import SwiftUI
import RealityKit
import ARKit

struct ThirdTabView: View {
    @State private var sz: Float = 1.0

    var body: some View {
        ZStack {
            // ARViewContainer is the AR view from your AR files.
            ARViewContainer(sz: $sz)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Button {
                    sz += 0.1  // Increase model size on tap
                } label: {
                    Text("Press me!")
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ThirdTabView()
}
