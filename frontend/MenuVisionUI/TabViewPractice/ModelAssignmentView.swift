
//  ModelAssignmentView.swift
//  MenuVision
//
//  Created by Spencer Le on 4/9/25.
//

import SwiftUI
import Combine

// MARK: - Data Models

/// Represents a single dish model associated with a menu item.
struct DishModel: Identifiable, Hashable, Decodable {
    /// Unique identifier for the dish.
    let dish_id: Int
    /// Name of the dish.
    let dish_name: String
    /// Optional description of the dish.
    let description: String?
    /// Optional list of ingredients for the dish.
    let ingredients: String?
    /// Price of the dish as a String from the API.
    let price: String
    /// Optional nutritional information for the dish.
    let nutritional_info: String?
    /// Optional allergen information for the dish.
    let allergens: String?
    /// ID of the associated AR model.
    let model_id: String
    /// Rating of the model associated with the dish.
    let model_rating: Int

    /// Computed property to conform to `Identifiable`.
    var id: Int { dish_id }

    /// Hashes the dish based on its `dish_id`.
    func hash(into hasher: inout Hasher) {
        hasher.combine(dish_id)
    }

    /// Compares two `DishModel` instances based on `dish_id`.
    static func == (lhs: DishModel, rhs: DishModel) -> Bool {
        return lhs.dish_id == rhs.dish_id
    }
}

/// Represents all models associated with a restaurant.
struct RestaurantModels: Decodable {
    /// The unique ID of the restaurant.
    let restaurant_id: String
    /// Name of the restaurant.
    let name: String
    /// Creation date of the record.
    let created_at: String
    /// List of dish models associated with the restaurant.
    let models: [DishModel]
}



/// ViewModel for managing dish models and assignment workflows.
class ModelAssignmentViewModel: ObservableObject {
    // Published properties for UI state
    /// Search text for filtering dishes.
        @Published var searchText = ""
        /// List of all fetched dishes.
        @Published var dishes: [DishModel] = []
        /// List of dishes filtered by search.
        @Published var filteredDishes: [DishModel] = []
        /// Indicates whether data is loading.
        @Published var isLoading = false
        /// Error message to display.
        @Published var errorMessage: String?
        /// Controls error alert visibility.
        @Published var showError = false

    // New Dish Form Properties
    @Published var newDishName = ""
    @Published var newDishDescription = ""
    @Published var newDishIngredients = ""
    @Published var newDishPrice = "" {
        didSet { // Input filtering for price
            if newDishPrice.isEmpty {
                return
            }
            let filtered = newDishPrice.filter { "0123456789.".contains($0) }
            if filtered != newDishPrice {
                newDishPrice = oldValue
                return
            }
            if newDishPrice.filter({ $0 == "." }).count > 1 {
                newDishPrice = oldValue
            }
        }
    }
    @Published var newDishNutritionalInfo = ""
    @Published var newDishAllergens = ""
    @Published var showNewDishForm = false

    // Success/Confirmation Alert Properties
    @Published var successMessage: String?
    @Published var showSuccess = false
    @Published var needsConfirmation = false
    @Published var selectedDish: DishModel?

    // Stored context (passed from View)
    var currentModelId: String?
    var currentUploadedBy: String? // User ID as String
    var currentRestaurantId: String? // Store restaurantId for potential re-fetch

    /// Internal cancellables for Combine.
        private var cancellables = Set<AnyCancellable>()

        /// Initializes a new instance of `ModelAssignmentViewModel`.
        init() {}

    /// Fetches restaurant models from the server.
    func fetchRestaurantModels(restaurantId: String) {
        self.currentRestaurantId = restaurantId // Store for potential later use
        isLoading = true
        errorMessage = nil

        guard let url = URL(
            string:
                "https://menu-vision-b202af7ea787.herokuapp.com/ar/restaurant/\(restaurantId)/models"
        ) else {
            // Handle invalid URL locally
            self.errorMessage = "Internal Error: Invalid URL structure."
            self.showError = true
            self.isLoading = false
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output -> Data in // Validate HTTP response
                guard let response = output.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode)
                else {
                    let errorDetail =
                        String(data: output.data, encoding: .utf8) ?? "No details"
                    print(
                        "Server Error (\((output.response as? HTTPURLResponse)?.statusCode ?? 0)): \(errorDetail)"
                    )
                    throw URLError(
                        .badServerResponse,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Server error fetching dishes: \(errorDetail)",
                        ]
                    )
                }
                print(
                    "Raw JSON (Dishes): \(String(data: output.data, encoding: .utf8) ?? "Could not convert")"
                )
                return output.data
            }
            .decode(type: RestaurantModels.self, decoder: JSONDecoder()) // Decode the expected structure
            .receive(on: DispatchQueue.main) // Update UI on main thread
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    // Handle specific errors or provide generic message
                    if let urlError = error as? URLError, urlError.code == .badServerResponse {
                        self?.errorMessage = urlError
                            .localizedDescription // Show server error detail
                    } else if error is DecodingError {
                        self?.errorMessage =
                            "Failed to parse restaurant data. Please try again."
                        print("Decoding Error: \(error)")
                    } else {
                        self?.errorMessage =
                            "Network error fetching dishes: \(error.localizedDescription)"
                    }
                    self?.showError = true
                    print("Fetch Dishes Error: \(error)")
                }
            }, receiveValue: { [weak self] response in
                // Process fetched models to display unique dishes
                var uniqueDishesDict = [Int: DishModel]()
                for model in response.models {
                    if uniqueDishesDict[model.dish_id] == nil {
                        // Keep the first instance of each dish
                        uniqueDishesDict[model.dish_id] = model
                    }
                }
                let uniqueDishes = Array(uniqueDishesDict.values).sorted {
                    $0.dish_name < $1.dish_name
                }
                self?.dishes = uniqueDishes
                self?.filterDishes(searchText: self?.searchText ?? "") // Apply current filter
            })
            .store(in: &cancellables)
    }

    /// Filters dishes by search text.
    func filterDishes(searchText: String) {
        if searchText.isEmpty {
            filteredDishes = dishes
        } else {
            let lowercasedSearchText = searchText.lowercased()
            filteredDishes = dishes.filter {
                $0.dish_name.lowercased().contains(lowercasedSearchText)
            }
        }
    }

    /// Associates an AR model to an existing dish.
    func addModelToExistingDish(dishId: Int, modelId: String, uploadedBy: String) {
        // Validate User ID format
        guard let uploadedById = Int(uploadedBy) else {
            self.errorMessage = "Invalid User ID format."
            self.showError = true
            return
        }

        guard let url = URL(
            string:
                "https://menu-vision-b202af7ea787.herokuapp.com/ar/dish/\(dishId)/add_model"
        ) else {
            self.errorMessage = "Internal Error: Invalid URL structure for adding model."
            self.showError = true
            return
        }

        let parameters: [String: Any] = ["model_id": modelId, "uploaded_by": uploadedById]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            self.errorMessage =
                "Failed to prepare data for adding model: \(error.localizedDescription)"
            self.showError = true
            return
        }

        makeNetworkRequest(request: request, successMessageBase: "Model successfully added")
    }
    /// Adds a new dish with a model to a restaurant.
    func addNewDishWithModel(restaurantId: String, modelId: String, uploadedBy: String) {
        // --- Data Validation ---
        let trimmedDishName = newDishName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrice = newDishPrice.trimmingCharacters(in: .whitespacesAndNewlines)

        // Name check (should be pre-filled, but validate anyway)
        if trimmedDishName.isEmpty {
            errorMessage = "Dish Name is missing."
            showError = true
            return
        }
        // Price checks
        if trimmedPrice.isEmpty || trimmedPrice == "." {
            errorMessage = "Price is required and must be a valid number."
            showError = true
            return
        }
        guard let priceValue = Double(trimmedPrice), priceValue > 0 else {
            errorMessage = "Please enter a valid positive price (e.g., 9.99)."
            showError = true
            return
        }
        // User ID check
        guard let uploadedById = Int(uploadedBy) else {
            errorMessage = "Invalid User ID format."
            showError = true
            return
        }
        // --- End Validation ---

        guard let url = URL(
            string: "https://menu-vision-b202af7ea787.herokuapp.com/ar/dish_with_model"
        ) else {
            self.errorMessage = "Internal Error: Invalid URL structure for creating dish."
            self.showError = true
            return
        }

        let parameters: [String: Any] = [
            "restaurant_id": restaurantId,
            "dish_name": trimmedDishName,
            "description": newDishDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            "ingredients": newDishIngredients.trimmingCharacters(in: .whitespacesAndNewlines),
            "price": trimmedPrice, // Send validated string price
            "nutritional_info": newDishNutritionalInfo.trimmingCharacters(in: .whitespacesAndNewlines),
            "allergens": newDishAllergens.trimmingCharacters(in: .whitespacesAndNewlines),
            "model_id": modelId,
            "uploaded_by": uploadedById,
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            self.errorMessage =
                "Failed to prepare data for new dish: \(error.localizedDescription)"
            self.showError = true
            return
        }

        makeNetworkRequest(
            request: request,
            successMessageBase: "New dish created successfully"
        ) { [weak self] success in
            if success {
                self?.resetNewDishForm() // Reset form fields on success
                // Optionally re-fetch dishes after adding a new one
                if let restId = self?.currentRestaurantId {
                    self?.fetchRestaurantModels(restaurantId: restId)
                }
            }
        }
    }

    /// Makes a generic network request.
    private func makeNetworkRequest(
        request: URLRequest,
        successMessageBase: String,
        completionHandler: ((Bool) -> Void)? = nil
    ) {
        isLoading = true
        errorMessage = nil // Clear previous errors

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                guard let response = output.response as? HTTPURLResponse else {
                    throw URLError(.cannotParseResponse)
                }
                guard (200...299).contains(response.statusCode) else {
                    let errorDetail =
                        String(data: output.data, encoding: .utf8) ?? "No details"
                    print("Server Error (\(response.statusCode)): \(errorDetail)")
                    var serverMessage = "Server returned status \(response.statusCode)."
                    if let json = try? JSONSerialization.jsonObject(with: output.data) as?
                        [String: Any],
                       let message = json["message"] as? String ?? json["error"] as? String
                    {
                        serverMessage += " \(message)"
                    } else if !errorDetail.isEmpty && errorDetail != "No details" {
                        serverMessage += " \(errorDetail)"
                    }
                    throw URLError(
                        .badServerResponse,
                        userInfo: [NSLocalizedDescriptionKey: serverMessage]
                    )
                }
                print(
                    "Success Response: \(String(data: output.data, encoding: .utf8) ?? "Could not convert")"
                )
                return output.data
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] taskCompletion in
                self?.isLoading = false
                switch taskCompletion {
                case .finished:
                    // Handled in receiveValue or assumed success if no value needed
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription // Show specific error
                    self?.showError = true
                    completionHandler?(false) // Signal failure
                }
            }, receiveValue: { [weak self] data in
                // Try to parse success message from response, otherwise use default
                var message = successMessageBase
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let serverMsg = json["message"] as? String
                {
                    message = serverMsg
                }
                self?.successMessage = message
                self?.showSuccess = true
                completionHandler?(true) // Signal success
            })
            .store(in: &cancellables)
    }

    /// Makes a generic network request.
    private func resetNewDishForm() {
        // Don't reset newDishName as it's set when form is shown
        newDishDescription = ""
        newDishIngredients = ""
        newDishPrice = ""
        newDishNutritionalInfo = ""
        newDishAllergens = ""
        showNewDishForm = false
    }
    
    /// Confirms adding a model to the selected dish.
    func confirmAddModelToDish() {
        guard let dish = selectedDish, let modelId = currentModelId,
              let uploadedBy = currentUploadedBy
        else {
            errorMessage = "Internal error: Missing data for adding model."
            showError = true
            resetConfirmationState()
            return
        }
        addModelToExistingDish(
            dishId: dish.dish_id,
            modelId: modelId,
            uploadedBy: uploadedBy
        )
        resetConfirmationState()
    }

    /// Handles when a dish is selected.
    func handleDishSelection(dish: DishModel) {
        // Ensure context is available before triggering confirmation
        guard let modelId = currentModelId, let uploadedBy = currentUploadedBy else {
            print("Error: Missing modelId or uploadedBy when selecting dish.")
            errorMessage = "Internal error occurred. Please try again."
            showError = true
            return
        }
        self.selectedDish = dish
        self.needsConfirmation = true // Trigger confirmation alert
    }

    private func resetConfirmationState() {
        needsConfirmation = false
        selectedDish = nil
    }
}

/// Main view for assigning AR models to dishes.
struct ModelAssignmentView: View {
    // StateObject for the ViewModel lifecycle tied to this view
    @StateObject private var viewModel = ModelAssignmentViewModel()
    // Input properties required when creating this view
    let restaurantId: String
    let modelId: String // The new model being assigned
    let uploadedBy: String // The user ID (as String) who uploaded the model

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack { // Overlay loading indicator
                // Use a background consistent with login/signup if desired, e.g., Color.slate100 or Color.white
                // Color.white.edgesIgnoringSafeArea(.all) // Example background
                VStack(spacing: 16) { // Added spacing
                    // Search Bar - Apply custom style
                    TextField("Search for an existing dish", text: $viewModel.searchText)
                        .customTextFieldStyle() // Apply custom text field style
                        .onChange(of: viewModel.searchText) {
                            viewModel.filterDishes(searchText: $0)
                        }
                        .padding(.horizontal)
                        .padding(.top) // Add padding top

                    // Conditional Content
                    if viewModel.filteredDishes.isEmpty && !viewModel.searchText.isEmpty {
                        noResultsView // Show "Create New" option
                            .padding(.horizontal) // Add padding to match search bar
                    } else {
                        dishesList // Show list of existing dishes
                    }
                }
                .navigationTitle("Assign to Dish")
                .onAppear {
                    // Pass initial context to ViewModel when view appears
                    viewModel.currentModelId = modelId
                    viewModel.currentUploadedBy = uploadedBy
                    viewModel.fetchRestaurantModels(restaurantId: restaurantId) // Fetch data
                }
                // Alerts managed by ViewModel state
                .alert(
                    "Error",
                    isPresented: $viewModel.showError,
                    presenting: viewModel.errorMessage
                ) { message in
                    Button("OK") {} // Default dismiss button
                } message: { message in
                    Text(message) // Display the error message from ViewModel
                }
                .alert(
                    "Success",
                    isPresented: $viewModel.showSuccess,
                    presenting: viewModel.successMessage
                ) { message in
                    Button("OK") { presentationMode.wrappedValue.dismiss() } // Dismiss view on success
                } message: { message in
                    Text(message) // Display the success message
                }
                .alert(
                    "Confirm Add Model",
                    isPresented: $viewModel.needsConfirmation,
                    presenting: viewModel.selectedDish
                ) { dish in
                    Button("Cancel", role: .cancel) {}
                    Button("Confirm") { viewModel.confirmAddModelToDish() }
                } message: { dish in
                    Text(
                        "The dish \"\(dish.dish_name)\" may already have AR models. Add this new model to it?"
                    )
                }
                // Sheet for creating a new dish
                .sheet(isPresented: $viewModel.showNewDishForm) {
                    // Pass the *same* ViewModel instance to the sheet
                    NewDishFormView(
                        viewModel: viewModel,
                        restaurantId: restaurantId,
                        modelId: modelId,
                        uploadedBy: uploadedBy
                    )
                }

                // Loading Indicator Overlay
                if viewModel.isLoading {
                    ProgressView("Loading...") // Added text for clarity
                        .scaleEffect(1.5)
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Center it
                        .ignoresSafeArea()
                }
            }
        }
    }

    // MARK: Subviews (Extracted for Clarity)

    private var dishesList: some View {
        List(viewModel.filteredDishes) { dish in
            Button {
                viewModel.handleDishSelection(dish: dish)
            } label: { // Use label for content
                HStack(alignment: .center, spacing: 12) { // Added alignment and spacing
                    ZStack(alignment: .topTrailing) {
                        if let thumbnail = loadDishThumbnail(modelID: dish.model_id) {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(8)
                        } else {
                            // Fallback Placeholder
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        }
                    }
                    .frame(width: 60, height: 60)

                    // Text Content
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dish.dish_name).font(.headline).foregroundColor(.primary) // Use primary color
                        if let desc = dish.description, !desc.isEmpty {
                            Text(desc).font(.subheadline).foregroundColor(.secondary).lineLimit(2)
                        }
                        // Use the price formatting you prefer (e.g., .green or .orange300)
                        Text(formatPrice(dish.price)).font(.subheadline).foregroundColor(.green)
                    }

                    Spacer() // Push content to leading edge

                    Image(systemName: "chevron.right") // Add indicator for tappable row
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8) // Add vertical padding inside the row
                // .padding(.horizontal, 4) // Horizontal padding might not be needed with List style
                .contentShape(Rectangle()) // Make entire row tappable
            }
            .buttonStyle(PlainButtonStyle()) // Use plain style to avoid default list button appearance
            // .listRowInsets(EdgeInsets()) // Adjust list row insets if needed
        }
        .listStyle(PlainListStyle()) // Keep plain list style
    }

    private var noResultsView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("No dishes found matching '\(viewModel.searchText)'")
                .font(.headline) // Style title text
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .multilineTextAlignment(.center)

            Button {
                viewModel.newDishName = viewModel.searchText // Pre-fill name
                viewModel.showNewDishForm = true // Show the form sheet
            } label: {
                Text("Create new dish: \(viewModel.searchText)")
                    // Use custom button style - assuming customBlue is defined
                    // .customButtonStyle()
                    // OR replicate style manually if customButtonStyle uses specific colors/fonts
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 14) // Match customButtonStyle padding
                    .frame(maxWidth: .infinity)
                    .background(Color.orange300) // Use consistent theme color
                    .cornerRadius(12) // Match customButtonStyle corner radius
                    .shadow(
                        color: Color.orange300.opacity(0.4),
                        radius: 2,
                        x: 0,
                        y: 1
                    ) // Match shadow
            }
            // .padding(.horizontal) // Keep button padding within the view padding
            Spacer()
        }
        .padding(.top, 30)
    }

    // MARK: - Helper Functions

    // Helper function to load thumbnail from local documents directory
    private func loadDishThumbnail(modelID: String) -> UIImage? {
        print("Attempting to load thumbnail for modelID: \(modelID)") // Log requested ID
        let fileManager = FileManager.default
        let filename = "\(modelID).png"
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not access documents directory.")
            return nil
        }

        let fileURL = documentsURL.appendingPathComponent(filename)
        print("Checking for thumbnail at path: \(fileURL.path)") // Log constructed path

        if fileManager.fileExists(atPath: fileURL.path) {
            print("Thumbnail file FOUND at path: \(fileURL.path)")
            if let image = UIImage(contentsOfFile: fileURL.path) {
                print("Successfully loaded UIImage for modelID: \(modelID)")
                return image
            } else {
                print(
                    "Error: Failed to load UIImage from path even though file exists: \(fileURL.path)"
                )
                return nil
            }
        } else {
            print("Thumbnail file NOT FOUND at path: \(fileURL.path)")
            return nil
        }
    }

    // Helper to format price string (consider using NumberFormatter for locale)
    private func formatPrice(_ priceString: String) -> String {
        guard let priceDouble = Double(priceString) else {
            return "$\(priceString)"
        } // Fallback
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        // formatter.locale = Locale.current // Optional: Use user's locale
        return formatter.string(from: NSNumber(value: priceDouble)) ??
            String(format: "$%.2f", priceDouble)
    }
}

/// View for creating a new dish and assigning a model.
struct NewDishFormView: View {
    @ObservedObject var viewModel: ModelAssignmentViewModel // Use shared ViewModel
    let restaurantId: String
    let modelId: String
    let uploadedBy: String // User ID as String

    @Environment(\.presentationMode) var presentationMode

    // Helper for required price label
    private var priceLabel: Text { Text("Price ") + Text("*").foregroundColor(.red) }

    var body: some View {
        NavigationView {
            Form {
                Section("Dish Information") { // Use String directly for header
                    // Dish Name (Non-Editable Display)
                    HStack {
                        Text("Dish Name") // Label
                        Spacer()
                        Text(viewModel.newDishName) // Display value
                            .foregroundColor(.gray) // Indicate non-editable
                            .multilineTextAlignment(.trailing)
                    }

                    // Other Fields (Editable) - Apply custom style
                    TextField(
                        "Description (Optional)",
                        text: $viewModel.newDishDescription,
                        axis: .vertical
                    )
                    .customTextFieldStyle() // Apply custom style
                    .lineLimit(3...5)

                    TextField(
                        "Ingredients (Optional)",
                        text: $viewModel.newDishIngredients,
                        axis: .vertical
                    )
                    .customTextFieldStyle() // Apply custom style
                    .lineLimit(3...5)

                    // Price Field (Numeric Input) - Apply custom style
                    HStack {
                        priceLabel
                        Spacer()
                        TextField("e.g., 9.99", text: $viewModel.newDishPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    .customTextFieldStyle() // Apply style to the HStack containing the TextField
                }

                Section("Additional Information (Optional)") {
                    TextField(
                        "Nutritional Info",
                        text: $viewModel.newDishNutritionalInfo,
                        axis: .vertical
                    )
                    .customTextFieldStyle() // Apply custom style
                    .lineLimit(3...5)
                    TextField(
                        "Allergens",
                        text: $viewModel.newDishAllergens,
                        axis: .vertical
                    )
                    .customTextFieldStyle() // Apply custom style
                    .lineLimit(2...4)
                }

                Section {
                    // Create Dish Button - Apply custom style
                    Button {
                        viewModel.addNewDishWithModel(
                            restaurantId: restaurantId,
                            modelId: modelId,
                            uploadedBy: uploadedBy
                        )
                    } label: {
                        Text("Create Dish and Assign Model")
                        // Use custom button style
                        // .customButtonStyle()
                        // OR replicate style manually
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 14) // Match padding
                            .background(Color.orange300) // Match color
                            .cornerRadius(12) // Match corner radius
                            .shadow(
                                color: Color.orange300.opacity(0.4),
                                radius: 2,
                                x: 0,
                                y: 1
                            ) // Match shadow
                    }
                    // Disable button if price is empty
                    .disabled(viewModel.newDishPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .listRowInsets(EdgeInsets()) // Remove form padding for button if needed
                }
            }
            .navigationTitle("New Dish Details")
            .navigationBarTitleDisplayMode(.inline) // Keep title inline
            .toolbar { // Use .toolbar for navigation items
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
            // Error alerts are shown by the presenting ModelAssignmentView
        }
    }
}

// MARK: - Preview
/// Preview provider for `ModelAssignmentView`.
struct ModelAssignmentViewPreview: PreviewProvider {
    static var previews: some View {
        // --- How to get user_id for the preview ---
        // Attempt to get from UserDefaults, provide a default if missing
        let previewUserIdInt = UserDefaults.standard.integer(forKey: "user_id")
        let previewUploadedBy = (previewUserIdInt != 0) ? String(previewUserIdInt) : "1" // Default to "1" i

        // --- Example usage for preview ---
        ModelAssignmentView(
            restaurantId: "ChIJ92rcyJWDRoYRotK6QCjsFf8", // Example Google Place ID
            modelId: "previewModel123",
            uploadedBy: previewUploadedBy // Use fetched or default user ID string
        )
    }
}
