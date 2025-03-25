import SwiftUI
import RealityKit
import ARKit

struct FirstTabView: View {
    
    @StateObject private var viewManager = ARViewManager();
    @State private var tappedIcon: Int = 0;
    
    var body: some View {
        ZStack {
            // ARViewContainer is the AR view from your AR files.
            ARViewContainer(viewManager: viewManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(viewManager.getModelMap().sorted(by: { $0.key < $1.key }), id: \.key) { id, value in
                            Button(
                                action: {
                                    print("Selected: \(id)")
                                    viewManager.changeModel(index: id);
                                    tappedIcon = id;
                                })
                            {
                                Image(value)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 70)
                                    .frame(width: 70)
                                    .background(tappedIcon == id ? Color(hex: "ff3f00").opacity(0.5) : Color(hex: "73edad").opacity(0.4))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .scrollTransition(.interactive, axis: .horizontal) { effect, phase in
                                        effect
                                            .scaleEffect(phase.isIdentity ? 1.0 : 0.95)
                                    }

                            }
                            .foregroundColor(Color.init(hex: "73edad"))
                            .padding(5)
                        }
                    }
                    .frame(height: 70)
                    .background(Color.clear.allowsHitTesting(false))
                    .padding()
                }

            }
        }
    }
}

#Preview {
    FirstTabView()
}


