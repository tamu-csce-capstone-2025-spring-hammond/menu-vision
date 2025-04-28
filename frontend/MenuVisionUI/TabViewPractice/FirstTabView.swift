import SwiftUI
import RealityKit
import ARKit

/// View for the first tab of the app, showing an AR scene with menu item models that can be voted on.
struct FirstTabView: View {

    /// Manages the ARView and model selection logic.
        @StateObject private var viewManager = ARViewManager()
        /// Index of the currently selected model.
        @State private var modelIndex: Int = 0
        /// Indicates whether freestyle mode is enabled.
        @State private var freestyleMode: Bool = false

        /// Controls the display of an alert.
        @State private var showAlert = false
        /// Message to display in the alert.
        @State private var alertMessage = ""

        /// Text entered by the user when reporting a dish.
        @State private var reportText: String = ""

        /// Controls the display of the report modal.
        @State private var showReportModal: Bool = false
        /// Controls the display of the information modal.
        @State private var showInformationModal: Bool = false

        /// Refreshes the UI manually.
        @State var refreshUI: Bool = false

        /// Environment object containing dish model mappings.
        @EnvironmentObject var dishMapping: DishMapping

        /// URL for documents directory to load images.
        @State private var documentsURL: URL?

        /// Unique view ID to force view refresh.
        @State private var viewID = UUID()

        /// Current user's voting status for the model ("up", "down", or nil).
        @State private var userVoteStatus: String? = nil


    /// Repeatedly polls until all AR models are finished loading, then fetches user vote status.
    private func pollForLoadingCompletion(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if (!dishMapping.isFinishedLoading()){
                pollForLoadingCompletion();
            } else {
                // Once loading is finished, check the initial vote status
                fetchUserVoteStatusForCurrentModel()
            }
        }
    }

    /// Fetches the user's vote status (upvote or downvote) for the currently selected model.
    private func fetchUserVoteStatusForCurrentModel() {
        let modelId = viewManager.getCurrentModelID()
        let userId = UserDefaults.standard.integer(forKey: "user_id")

        guard !modelId.isEmpty, userId != 0 else {
            print("Cannot fetch vote status: Model ID or User ID not available")
            // Reset status if modelId is not available
            DispatchQueue.main.async {
                self.userVoteStatus = nil
            }
            return
        }

        guard let url = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/ar/model/\(modelId)/check-vote/\(userId)") else {
            print("Invalid URL for check-vote")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Check-vote uses GET

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching vote status: \(error)")
                DispatchQueue.main.async {
                    self.userVoteStatus = nil // Reset on error
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response from check-vote")
                 DispatchQueue.main.async {
                    self.userVoteStatus = nil // Reset on invalid response
                }
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        if let review = json["review"] as? String, (review == "up" || review == "down") {
                            self.userVoteStatus = review // Update status with "up" or "down"
                            print("Fetched vote status: \(review) for model \(modelId)")
                        } else {
                            self.userVoteStatus = nil // No vote found
                             print("No vote found for model \(modelId)")
                        }
                    }
                } else {
                     DispatchQueue.main.async {
                         self.userVoteStatus = nil // Error parsing JSON
                         print("Error parsing JSON from check-vote")
                     }
                }
            } else {
                // Handle other status codes, like 404 (model not found) or 200 with "No vote found" message
                 if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                     if json["message"] as? String == "No vote found" {
                         DispatchQueue.main.async {
                             self.userVoteStatus = nil // Explicitly set to nil if message indicates no vote
                             print("API returned 'No vote found' for model \(modelId)")
                         }
                     } else {
                         print("check-vote received unexpected status code: \(httpResponse.statusCode), message: \(json["message"] ?? "N/A")")
                          DispatchQueue.main.async {
                             self.userVoteStatus = nil // Treat other errors as no vote found
                          }
                     }
                 } else {
                     print("check-vote received unexpected status code: \(httpResponse.statusCode) and couldn't parse JSON.")
                     DispatchQueue.main.async {
                         self.userVoteStatus = nil // Treat other errors as no vote found
                      }
                 }
            }
        }.resume()
    }


    /// Sends a POST request to upvote or downvote a model and fetches the updated vote status.
    private func callVoteAPI(endpoint: String, modelId: String, userId: Int) {
        // Construct the URL
        guard let url = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/ar/model/\(modelId)/\(endpoint)/\(userId)") else {
            print("Invalid URL for \(endpoint)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error calling \(endpoint): \(error)")
                // Consider showing an error to the user
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response for \(endpoint), unexpected status code: \(String(describing: response))")
                 // Consider showing an error to the user
                return
            }
            // Optionally handle the response data - currently just prints success
            print("\(endpoint) successful for model: \(modelId)")

            // MARK: - Fetch vote status after successful vote
            fetchUserVoteStatusForCurrentModel()

        }.resume()
    }

    /// Performs the upvote or downvote action for the currently selected model.
    private func voteAction(endpoint: String) {
        let modelId = viewManager.getCurrentModelID()
        if modelId.isEmpty {
            print("Could not get current model ID or model ID is empty")
            return
        }

        let userId = UserDefaults.standard.integer(forKey: "user_id")
        // Ensure user ID is valid before voting
        guard userId != 0 else {
            print("User ID not available. Cannot vote.")
            // Optionally show an alert to the user asking them to log in or similar
            return
        }

        // Optimistically update the UI (optional, but makes it feel snappier)
        // If the API call fails, fetchUserVoteStatus will reset it
        DispatchQueue.main.async {
            self.userVoteStatus = (endpoint == "upvote") ? "up" : "down"
        }


        callVoteAPI(endpoint: endpoint, modelId: modelId, userId: userId)
    }

    var body: some View {
        VStack{

            if (dishMapping.finishedDownloading){
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
                                        // MARK: - Fetch vote status after swipe
                                        fetchUserVoteStatusForCurrentModel()

                                        print(modelIndex);
                                    }

                                    /* else {
                                        //vertical drag occured
                                    }*/
    }
                        )

                    VStack {

                        // Removed the name and toggle from here, moving to toolbar

                        Spacer()

                        // Container for Vote Buttons (aligned right)
                        HStack {
                            Spacer() // Pushes vote buttons to the right
                            VStack(spacing: 15) { // Vote buttons stacked vertically
                                Button(action: {
                                    voteAction(endpoint: "upvote")
                                }) {
                                    // MARK: - Conditional Upvote Icon
                                    Image(systemName: userVoteStatus == "up" ? "hand.thumbsup.circle.fill" : "hand.thumbsup.circle")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.green)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }

                                Button(action: {
                                    voteAction(endpoint: "downvote")
                                }) {
                                     // MARK: - Conditional Downvote Icon
                                    Image(systemName: userVoteStatus == "down" ? "hand.thumbsdown.circle.fill" : "hand.thumbsdown.circle")
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
                                                     // MARK: - Fetch vote status after thumbnail tap
                                                    fetchUserVoteStatusForCurrentModel()
                                                }) {
                                                ModelThumbnail(
                                                    id: id,
                                                    filename: value.0,
                                                    documentsURL: documentsURL,
                                                    isSelected: modelIndex == id
                                                )
                                            }
                                            .foregroundColor(Color.init(hex: "73edad")) // Using hex directly from your original code
                                            .padding(5)
                                            .id(id)
                                        }
                                    }
                                    .frame(height: 70)
                                    .background(Color.clear.allowsHitTesting(false))
                                    .padding()
                                }
                                .onAppear {
                                    // Ensure scrolling to the initial model index
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        scrollProxy.scrollTo(modelIndex, anchor: .center)
                                    }
                                }
                                .onChange(of: modelIndex) { newIndex in
                                    // Scroll when modelIndex changes (e.g., from swipe)
                                    withAnimation {
                                        scrollProxy.scrollTo(newIndex, anchor: .center)
                                    }
                                }


                            }
                            .onAppear {
                                print("howdy, ", dishMapping.finishedLoading);

                                documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first;

                                // Start polling for loading completion
                                // Once loading is finished, pollForLoadingCompletion calls fetchUserVoteStatusForCurrentModel
                                pollForLoadingCompletion();

                                DispatchQueue.main.async {
                                    modelIndex = viewManager.currentIndex();
                                    self.refreshUI.toggle(); // Still kept this, might be for other reasons

                                    if (dishMapping.getModels().isEmpty){
                                        alertMessage = "Could not download AR models for this restaurant. Either nothing has been uploaded yet or the internet connection may be weak."
                                        showAlert = true

                                    }
                                }

                            }
                            .id(viewID) // Still kept this
                            .onDisappear{
                                print("Happened");
                                dishMapping.setStartedLoading();
                                dishMapping.goToID = ""; //reset so that it doesn't keep going to the random item that was selected that one time
                                viewID = UUID(); // Still kept this
                                // Reset vote status when the view disappears
                                userVoteStatus = nil
                            }

                        }
                    }
            }
            else{
                
                ProgressView(value: Double(dishMapping.modelCount), total: Double(dishMapping.totalModels))
                    .frame(width: 150, height: 15)
//                    .progressViewStyle(LinearProgressViewStyle())
//                    .padding()
//                    .scaleEffect(1.3)

                Text("Loading models...")
            }

        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("No Models Found"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        // MARK: - Navigation Bar Items
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
        // MARK: - Information Modal (Original)
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
        // MARK: - Report Modal (Original)
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
                    // You might want to get the current model ID here to include in the report
                    print("Reporting model: \(viewManager.getCurrentModelID()) with text: \(reportText)")
                    // Call your report API endpoint here
                    showReportModal = false
                    reportText = "" // Clear the text field
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button("Cancel") {
                    showReportModal = false
                    reportText = "" // Clear the text field
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
            // Placeholder if image not found - you might want a better UI here
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 70, height: 70)
                .overlay(
                    Text("No Image")
                        .font(.caption2)
                        .foregroundColor(.white)
                )
        }
    }
}
