import SwiftUI
import RealityKit
import ARKit

struct ThirdTabView: View {
    
    @StateObject private var viewManager = ARViewManager();
    
    var body: some View {
        ZStack {
            // ARViewContainer is the AR view from your AR files.
            ARViewContainer(viewManager: viewManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Button {
                    viewManager.changeModel();
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
