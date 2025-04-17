import SwiftUI
import RealityKit
import ARKit

struct FirstTabView: View {
    
    @StateObject private var viewManager = ARViewManager();
    @State private var modelIndex: Int = 0;
    @State private var freestyleMode: Bool = false;
    
    @State private var reportText: String = "";
    
    @State private var showReportModal: Bool = false;
    @State private var showInformationModal: Bool = false;
    
    @State var refreshUI: Bool = false;
    
    @EnvironmentObject var dishMapping: DishMapping;
    
    @State private var documentsURL: URL?;
    
    private func pollForLoadingCompletion(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            if (!dishMapping.isFinishedLoading()){
                pollForLoadingCompletion();
            }
        }
    }
    
    private func callVoteAPI(endpoint: String, modelId: String, userId: Int) {
        // Construct the URL with blueprint prefix, modelId, endpoint, and userId in the path
        guard let url = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/ar/model/\(modelId)/\(endpoint)/\(userId)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // No need to set Content-Type or body as modelId is in the URL
        // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // let body: [String: Any] = ["model_id": modelId]
        // request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error calling \(endpoint): \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }
            // Optionally handle the response data
            print("\(endpoint) successful for model: \(modelId)")
        }.resume()
    }

    private func voteAction(endpoint: String) {
        let modelId = viewManager.getCurrentModelID()
        if modelId.isEmpty {
            print("Could not get current model ID or model ID is empty")
            return
        }
        
        let userId = UserDefaults.standard.integer(forKey: "user_id")
        callVoteAPI(endpoint: endpoint, modelId: modelId, userId: userId)
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
                        
                        // Container for Vote Buttons (aligned right)
                        HStack {
                            Spacer() // Pushes vote buttons to the right
                            VStack(spacing: 15) { // Vote buttons stacked vertically
                                Button(action: {
                                    voteAction(endpoint: "upvote")
                                }) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.green)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }

                                Button(action: {
                                    voteAction(endpoint: "downvote")
                                }) {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.red)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(.horizontal, 16) // Add horizontal padding to align with other buttons
                        .padding(.bottom, 10) // Add some space below vote buttons

                        // Container for Info/Flag Buttons
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
                                
                                // Flag Button (no longer grouped with vote buttons)
                                Button(action: {
                                    showReportModal = true;
                                }) {
                                    Image(systemName: "flag")
                                        .padding(8)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                
                                /* // REMOVED: Old structure grouping vote/flag
                                // Group Vote buttons and Flag button vertically
                                VStack(spacing: 10) { 
                                    // Upvote/Downvote Buttons stacked vertically
                                    VStack(spacing: 15) { // Adjust spacing between vertical buttons
                                        Button(action: {
                                            voteAction(endpoint: "upvote")
                                        }) {
                                            Image(systemName: "arrow.up.circle.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40) // Increased size
                                                .foregroundColor(.green)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }

                                        Button(action: {
                                            voteAction(endpoint: "downvote")
                                        }) {
                                            Image(systemName: "arrow.down.circle.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40) // Increased size
                                                .foregroundColor(.red)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                    }
                                    
                                    // Flag Button
                                    Button(action: {
                                        showReportModal = true;
                                    }) {
                                        Image(systemName: "flag")
                                            .padding(8)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                }
                                */
                            }
                            .padding(.horizontal, 16)

                            ScrollViewReader { scrollProxy in
                                ScrollView(.horizontal) {
                                    LazyHStack(spacing: 0) {
                                        ForEach(viewManager.getModelMap().sorted(by: { $0.key < $1.key }), id: \.key) { id, value in
                                            Button(
                                                action: {
                                                    print("Selected: \(id)")
                                                    viewManager.changeModel(index: id)
                                                    modelIndex = id
                                                }) {
                                                ModelThumbnail(
                                                    id: id,
                                                    filename: value.0,
                                                    documentsURL: documentsURL,
                                                    isSelected: modelIndex == id
                                                )
                                            }
                                            .foregroundColor(Color.init(hex: "73edad"))
                                            .padding(5)
                                            .id(id)
                                        }
                                    }
                                    .frame(height: 70)
                                    .background(Color.clear.allowsHitTesting(false))
                                    .padding()
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        scrollProxy.scrollTo(modelIndex, anchor: .center)
                                    }
                                }
                                .onChange(of: modelIndex) { newIndex in
                                    withAnimation {
                                        scrollProxy.scrollTo(newIndex, anchor: .center)
                                    }
                                }
                            }

                            .onAppear {
                                
                                print("howdy");
                                
                                DispatchQueue.main.async {
                                    dishMapping.setStartedLoading();
                                }
                                                                
                                documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first;
                                
                                //I know this is cooked forgive me
                                
                                pollForLoadingCompletion();
                                
                                modelIndex = viewManager.currentIndex();
                                
                                DispatchQueue.main.async {
                                    self.refreshUI.toggle()
                                }
                                
                            }
                            .onDisappear{
                                print("Happened");
                                dishMapping.setStartedLoading();
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
                        HStack(spacing: 12) {
                            Toggle("", isOn: $freestyleMode)
                                .toggleStyle(SwitchToggleStyle())
                                .frame(width: 50)
                            
                            Text("Freestyle")
                                .background(Color.white).opacity(0.95)
                                .foregroundColor(freestyleMode ? Color.orange300 : Color.gray)
                                .cornerRadius(4)
                                .font(.custom("Futura", size: 16))
                               
                        }
                        .onChange(of: freestyleMode) {
                            viewManager.modeSwitch()
                        }
                    }
                }
        .sheet(isPresented: $showInformationModal) {
            ScrollView{
                VStack(spacing: 20) {
                    Text("How To Use MenuVision™ AR")
                        .font(.headline)

                    Text("1. First hover your phone around your surroundings in order to allow MenuVision™ to detect a surface. Once a surface is found, the white overlay on the screen should disappear. (if it never appeared in the first place then you are likely already good to go)")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("2. Now tap on your screen at a point on the surface in front of you in order to place the menu item in that spot.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("3. MenuVision™ AR offers two separate modes which can be switched between using the toggle on the top right of the screen. The default mode is Casual mode which allows you to quickly swipe between menu items one by one with each one appearing in the same place. In Freestyle mode, you can place multiple menu items into your surroundings at the same time in order to compare and contrast. With Freestyle mode you must tap the surface to place each item while in Casual mode you only need to tap the surface one time.")
                        .multilineTextAlignment(.center)
                        .padding()

                    Text("4. The carousel at the bottom allows you to pick the menu item to place. You may either tap the icon on the slider or swipe left or right across the screen to swap between dishes. If a MenuItem is not accurate or contains some other form of issue you can report it to our team using the flag icon above the carousel to the right.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("5. To remove a menu item from the screen, long press the item. In Casual mode, you will need to tap a surface again to place the next item.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("6. If you would like to move an item to a different spot on the surface, drag it with your finger across the screen.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("7. In Freestyle mode, you can tap an item on the screen to see a label that shows the name of the dish.")
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
                Text("Report AR Dish")
                    .font(.headline)
                    .foregroundColor(Color.orange300)

                Text("Thank you for helping to keep MenuVision™ pristine!")
                    .multilineTextAlignment(.center)
                    .padding()
                                
                Text("Please describe the problem...");
                
                TextEditor(text: $reportText)
                                .frame(height: 150)  // Set a fixed height for the TextEditor
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .border(Color.gray, width: 1)


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

