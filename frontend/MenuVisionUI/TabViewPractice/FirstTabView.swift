import SwiftUI
import RealityKit
import ARKit

func nothing(){
    
}

struct FirstTabView: View {
    
    @StateObject private var viewManager = ARViewManager();
    @State private var modelIndex: Int = 0;
    @State private var freestyleMode: Bool = false;
    
    @State var refreshUI: Bool = false;
    
    @EnvironmentObject var dishMapping: DishMapping;
    
    @State private var documentsURL: URL?;
    
    private func pollForLoadingCompletion(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if (!dishMapping.isFinishedLoading()){
                pollForLoadingCompletion();
            }
        }
    }
    
    var body: some View {
        VStack{
            
            if (dishMapping.isFinishedDownloading()){
                ZStack{
                    // ARViewContainer is the AR view from your AR files.
                    ARViewContainer(viewManager: viewManager)
                        .edgesIgnoringSafeArea(.all)
                        .gesture(
                            DragGesture()
                                .onEnded { gesture in
                                    let horizontalDrag = gesture.translation.width;
                                    let verticalDrag = gesture.translation.height;

                                    if abs(horizontalDrag) > abs(verticalDrag) {
                                        
                                        if (horizontalDrag > 0){
                                            //right swipe occured
                                            
                                            viewManager.decrementModel();
                                            
                                        }
                                        else{
                                            viewManager.incrementModel()
                                        }
                                        
                                        modelIndex = viewManager.currentIndex();
                                        
                                        print(modelIndex);
                                    }

                                        

                                    /* else {
                                        //vertical drag occured
                                        
                                    }*/
    }
                        )
                    
                    VStack {
                        HStack {
                            
                            Button(action: nothing) {
                                BackIcon()
                                    .accentColor(.black)
                                    .padding(.horizontal, 10)
                                    .frame(minWidth: 30, minHeight: 30)
                            }
                            .background(Color.orange300.cornerRadius(7))
                            .padding(.leading, 16)
                            
                            
                            Spacer()
                            
                            Text("\(viewManager.getCurrentModelName())")
                                .foregroundColor(.white)
                                .padding(.leading, 16)
                            
                            Spacer()
                            
                            HStack {
                                    
                                
                                Toggle("", isOn: $freestyleMode)
                                    .toggleStyle(SwitchToggleStyle())
                                
                                    Text("Freestyle")
                                    .foregroundColor(Color.orange300)
                                    .padding(.trailing, 16)
                                }
                                .onChange(of: freestyleMode) {
                                    viewManager.modeSwitch();
                            }

                        }
                        
                                    
                        Spacer()
                                                                        
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 0) {
                                    ForEach(viewManager.getModelMap().sorted(by: { $0.key < $1.key }), id: \.key) { id, value in
                                        Button(
                                            action: {
                                                print("Selected: \(id)")
                                                viewManager.changeModel(index: id);
                                                modelIndex = id;
                                                
                                            })
                                        {
                                            
                                            if let documentsURL = documentsURL {
                                                let imagePath = documentsURL.appendingPathComponent(value.1 + ".png").path
                                                if let uiImage = UIImage(contentsOfFile: imagePath) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 70, height: 70)
                                                        .background(modelIndex == id ? Color(hex: "ff3f00").opacity(0.5) : Color(hex: "73edad").opacity(0.4))
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                        .scrollTransition(.interactive, axis: .horizontal) { effect, phase in
                                                            effect.scaleEffect(phase.isIdentity ? 1.0 : 0.95)
                                                        }
                                                } else {
                                                    Text("Image not found")
                                                        .frame(width: 70, height: 70)
                                                        .background(modelIndex == id ? Color(hex: "ff3f00").opacity(0.5) : Color(hex: "73edad").opacity(0.4))
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                }
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
                            .onAppear {
                                
                                documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first;
                                
                                pollForLoadingCompletion();
                                
                                refreshUI.toggle();
                                
                            }
                        }
                    }
            }
            else{
                Text("Loading models...")
            }
            
        }
        
    }
}

#Preview {
    FirstTabView()
}




