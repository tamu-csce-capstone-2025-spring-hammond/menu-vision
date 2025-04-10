import SwiftUI
import RealityKit
import ARKit

func nothing(){
    
}

struct FirstTabView: View {
    
    @StateObject private var viewManager = ARViewManager();
    @State private var modelIndex: Int = 0;
    @State private var freestyleMode: Bool = false;
    
    @State private var showReportModal: Bool = false;
    @State private var showInformationModal: Bool = false;
    
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
                                                        
                            //Spacer()
                            
                            /*Text("\(viewManager.getCurrentModelName())")
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
                            }*/

                        }
                        
                                    
                        Spacer()
                        
                        HStack {
                                Button(action: {
                                    showInformationModal = true;
                                }) {
                                    Image(systemName: "info.circle")
                                        .padding(8)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }

                                Spacer()

                                Button(action: {
                                    showReportModal = true;
                                }) {
                                    Image(systemName: "flag")
                                        .padding(8)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, 16)

                                                                        
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 0) {
                                    ForEach(viewManager.getModelMap().sorted(by: { $0.key < $1.key }), id: \.key) { id, value in
                                        Button(
                                            action: {
                                                print("Selected: \(id)")
                                                viewManager.changeModel(index: id);
                                                modelIndex = id;
                                                
                                                print("The val: ", value.0);

                                            })
                                        {
                                            
                                            ModelThumbnail(
                                                        id: id,
                                                        filename: value.0,
                                                        documentsURL: documentsURL,
                                                        isSelected: modelIndex == id
                                                    )
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
                                
                                //I know this is cooked forgive me
                                
                                pollForLoadingCompletion();
                                
                                refreshUI.toggle(); //once model map is loaded into refresh the view by toggling this variable
                                
                            }
                        }
                    }
            }
            else{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.3)

                Text("Loading models...")
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Text(viewManager.getCurrentModelName())
                            .foregroundColor(.white)
                            .padding(.leading, 20);
                    }
                    
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            Toggle("", isOn: $freestyleMode)
                                .toggleStyle(SwitchToggleStyle())
                                .frame(width: 50)
                            
                            Text("Freestyle")
                                .foregroundColor(Color.orange300)
                        }
                        .onChange(of: freestyleMode) {
                            viewManager.modeSwitch()
                        }
                    }
                }
        .sheet(isPresented: $showInformationModal) {
            ScrollView{
                VStack(spacing: 20) {
                    Text("How to use MenuVision™ AR")
                        .font(.headline)

                    Text("1. First hover your phone around your surroundings in order to allow MenuVision™ to detect a surface. Once a surface is found, the white overlay on the screen should disappear. (if it never appeared in the first place then you are likely already good to go)")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("2. Now tap on your screen at a point on the surface in front of you in order to place the menu item in that spot.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("3. MenuVision™ AR offers two separate modes which can be switched between using the toggle on the top right of the screen. The default mode is casual mode which allows you to quickly swipe between menu items one by one with each one appearing in the same place. In freestyle mode, you can place multiple menu items into your surroundings at the same time in order to compare and contrast. With freestyle mode you must tap the surface to place each item while in casual mode you only need to tap the surface one time.")
                        .multilineTextAlignment(.center)
                        .padding()

                    Text("4. The carousel at the bottom allows you to pick the menu item to place. You may either tap the icon on the slider or swipe left or right across the screen to swap between dishes. If a MenuItem is not accurate or contains some other form of issue you can report it to our team using the flag icon above the carousel to the right.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("5. To remove a menu item from the screen, long press the item. In casual mode you will need to tap a surface again to place the next item.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("6. If you would like to move an item to a different spot on the surface, drag it with your finger across the screen.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("7. In freestyle mode, you can tap an item on the screen to see a label that shows the name of the dish.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("8. Please enjoy MenuVision™ AR!")
                        .multilineTextAlignment(.center)
                        .padding()





                    
                    Button("Got it!") {
                        showInformationModal = false
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showReportModal) {
            VStack(spacing: 20) {
                Text("Report Content")
                    .font(.headline)

                Text("Are you sure you want to report this item?")
                    .multilineTextAlignment(.center)
                    .padding()

                Button("Submit Report") {
                    // handle report logic here
                    showReportModal = false
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button("Cancel") {
                    showReportModal = false
                }
            }
            .padding()
        }

        
    }
}

#Preview {
    FirstTabView()
}


struct ModelThumbnail: View {
    var id: Int
    var filename: String
    var documentsURL: URL?
    var isSelected: Bool

    var body: some View {
        
        let imagePath = documentsURL?.appendingPathComponent(filename + ".png").path ?? ""
        if let uiImage = UIImage(contentsOfFile: imagePath) {
            ZStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                if isSelected {
                    Color.orange
                        .opacity(0.5)
                        .blur(radius: 5)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .background(
                isSelected ? Color(hex: "ff3f00").opacity(0.5) : Color(hex: "73edad").opacity(0.4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .scrollTransition(.interactive, axis: .horizontal) { effect, phase in
                effect.scaleEffect(phase.isIdentity ? 1.0 : 0.95)
            }
            } else {
            Text("Image not found")
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

