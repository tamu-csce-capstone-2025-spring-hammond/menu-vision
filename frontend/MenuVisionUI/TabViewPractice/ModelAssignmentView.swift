////
////  ModelAssignmentView.swift
////  MenuVision
////
////  Created by Spencer Le on 4/9/25.
////
//
////
////  ModelAssignmentView.swift
////  MenuVision
////
//
//import SwiftUI
//import Combine
//
//struct DishModel: Identifiable, Hashable, Decodable {
//    let dish_id: Int
//    let dish_name: String
//    let description: String?
//    let ingredients: String?
//    let price: String  // String to match API response
//    let nutritional_info: String?
//    let allergens: String?
//    let model_id: String
//    let model_rating: Int
//    
//    var id: Int { dish_id }
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(dish_id)
//        hasher.combine(model_id)
//    }
//    
//    static func == (lhs: DishModel, rhs: DishModel) -> Bool {
//        return lhs.dish_id == rhs.dish_id && lhs.model_id == rhs.model_id
//    }
//}
//
//struct RestaurantModels: Decodable {
//    let restaurant_id: String
//    let name: String
//    let created_at: String
//    let models: [DishModel]
//}
//
//class ModelAssignmentViewModel: ObservableObject {
//    @Published var searchText = ""
//    @Published var dishes: [DishModel] = []
//    @Published var filteredDishes: [DishModel] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    @Published var showError = false
//    @Published var newDishName = ""
//    @Published var newDishDescription = ""
//    @Published var newDishIngredients = ""
//    @Published var newDishPrice = ""
//    @Published var newDishNutritionalInfo = ""
//    @Published var newDishAllergens = ""
//    @Published var showNewDishForm = false
//    @Published var successMessage: String?
//    @Published var showSuccess = false
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        $searchText
//            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
//            .removeDuplicates()
//            .sink { [weak self] searchText in
//                self?.filterDishes(searchText: searchText)
//            }
//            .store(in: &cancellables)
//    }
//    
//    func fetchRestaurantModels(restaurantId: String) {
//        isLoading = true
//        errorMessage = nil
//        
//        guard let url = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/ar/restaurant/\(restaurantId)/models") else {
//            self.errorMessage = "Invalid URL"
//            self.showError = true
//            self.isLoading = false
//            return
//        }
//        
//        URLSession.shared.dataTaskPublisher(for: url)
//            .map { output -> Data in
//                print("Raw JSON: \(String(data: output.data, encoding: .utf8) ?? "Could not convert to string")")
//                return output.data
//            }
//            .decode(type: RestaurantModels.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                self?.isLoading = false
//                
//                if case .failure(let error) = completion {
//                    self?.errorMessage = "Decoding error: \(error.localizedDescription)"
//                    self?.showError = true
//                    print("Decoding error: \(error)")
//                }
//            }, receiveValue: { [weak self] response in
//                self?.dishes = response.models
//                self?.filterDishes(searchText: self?.searchText ?? "")
//            })
//            .store(in: &cancellables)
//    }
//    
//    private func filterDishes(searchText: String) {
//        if searchText.isEmpty {
//            filteredDishes = dishes
//        } else {
//            filteredDishes = dishes.filter { dish in
//                dish.dish_name.lowercased().contains(searchText.lowercased())
//            }
//        }
//    }
//    
//    func addModelToExistingDish(dishId: Int, modelId: String, uploadedBy: String) {
//        isLoading = true
//        errorMessage = nil
//        
//        guard let url = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/ar/dish/\(dishId)/add_model") else {
//            self.errorMessage = "Invalid URL"
//            self.showError = true
//            self.isLoading = false
//            return
//        }
//        
//        // Convert uploadedBy to an integer if possible, or use 1 as default
//        let uploadedById = Int(uploadedBy) ?? 1
//        
//        let parameters: [String: Any] = [
//            "model_id": modelId,
//            "uploaded_by": uploadedById  // Send as integer
//        ]
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
//        } catch {
//            self.errorMessage = "Failed to encode parameters"
//            self.showError = true
//            self.isLoading = false
//            return
//        }
//        
//        URLSession.shared.dataTaskPublisher(for: request)
//            .map { output -> Data in
//                print("Response: \(String(data: output.data, encoding: .utf8) ?? "Could not convert to string")")
//                return output.data
//            }
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                if case .failure(let error) = completion {
//                    self?.isLoading = false
//                    self?.errorMessage = error.localizedDescription
//                    self?.showError = true
//                }
//            }, receiveValue: { [weak self] data in
//                self?.isLoading = false
//                
//                // Check if there's an error in the response
//                if let responseString = String(data: data, encoding: .utf8),
//                   responseString.contains("error") {
//                    self?.errorMessage = "API Error: \(responseString)"
//                    self?.showError = true
//                } else {
//                    self?.successMessage = "Model successfully added to dish"
//                    self?.showSuccess = true
//                }
//            })
//            .store(in: &cancellables)
//    }
//    
//    func addNewDishWithModel(restaurantId: String, modelId: String, uploadedBy: String) {
//        if newDishPrice.isEmpty {
//            errorMessage = "Price is required"
//            showError = true
//            return
//        }
//        
//        isLoading = true
//        errorMessage = nil
//        
//        guard let url = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/ar/dish_with_model") else {
//            self.errorMessage = "Invalid URL"
//            self.showError = true
//            self.isLoading = false
//            return
//        }
//        
//        // Convert uploadedBy to an integer if possible, or use 1 as default
//        let uploadedById = Int(uploadedBy) ?? 1
//        
//        let parameters: [String: Any] = [
//            "restaurant_id": restaurantId,
//            "dish_name": newDishName,
//            "description": newDishDescription,
//            "ingredients": newDishIngredients,
//            "price": newDishPrice,  // Send as string
//            "nutritional_info": newDishNutritionalInfo,
//            "allergens": newDishAllergens,
//            "model_id": modelId,
//            "uploaded_by": uploadedById  // Send as integer
//        ]
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
//        } catch {
//            self.errorMessage = "Failed to encode parameters"
//            self.showError = true
//            self.isLoading = false
//            return
//        }
//        
//        URLSession.shared.dataTaskPublisher(for: request)
//            .map { output -> Data in
//                print("Response: \(String(data: output.data, encoding: .utf8) ?? "Could not convert to string")")
//                return output.data
//            }
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                if case .failure(let error) = completion {
//                    self?.isLoading = false
//                    self?.errorMessage = error.localizedDescription
//                    self?.showError = true
//                }
//            }, receiveValue: { [weak self] data in
//                self?.isLoading = false
//                
//                // Check if there's an error in the response
//                if let responseString = String(data: data, encoding: .utf8),
//                   responseString.contains("error") {
//                    self?.errorMessage = "API Error: \(responseString)"
//                    self?.showError = true
//                } else {
//                    self?.resetNewDishForm()
//                    self?.successMessage = "New dish created successfully"
//                    self?.showSuccess = true
//                }
//            })
//            .store(in: &cancellables)
//    }
//    
//    private func resetNewDishForm() {
//        newDishName = ""
//        newDishDescription = ""
//        newDishIngredients = ""
//        newDishPrice = ""
//        newDishNutritionalInfo = ""
//        newDishAllergens = ""
//        showNewDishForm = false
//    }
//}
//
//struct ModelAssignmentView: View {
//    @StateObject private var viewModel = ModelAssignmentViewModel()
//    let restaurantId: String
//    let modelId: String
//    let uploadedBy: String
//    
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                VStack {
//                    // Search bar
//                    TextField("Search for a dish", text: $viewModel.searchText)
//                        .padding()
//                        .background(Color(.systemGray6))
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                    
//                    // No results view with option to create new dish
//                    if viewModel.filteredDishes.isEmpty && !viewModel.searchText.isEmpty {
//                        VStack(spacing: 20) {
//                            Text("No dishes found matching '\(viewModel.searchText)'")
//                                .foregroundColor(.secondary)
//                            
//                            Button(action: {
//                                viewModel.newDishName = viewModel.searchText
//                                viewModel.showNewDishForm = true
//                            }) {
//                                Text("Create new dish: \(viewModel.searchText)")
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.blue)
//                                    .cornerRadius(10)
//                            }
//                            .padding(.horizontal)
//                        }
//                        .padding(.top, 30)
//                    } else {
//                        // List of dishes
//                        List(viewModel.filteredDishes) { dish in
//                            Button(action: {
//                                viewModel.addModelToExistingDish(
//                                    dishId: dish.dish_id,
//                                    modelId: modelId,
//                                    uploadedBy: uploadedBy
//                                )
//                            }) {
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text(dish.dish_name)
//                                        .font(.headline)
//                                    
//                                    if let description = dish.description, !description.isEmpty {
//                                        Text(description)
//                                            .font(.subheadline)
//                                            .foregroundColor(.secondary)
//                                            .lineLimit(2)
//                                    }
//                                    
//                                    Text("$\(dish.price)")
//                                        .font(.subheadline)
//                                        .foregroundColor(.green)
//                                }
//                                .padding(.vertical, 4)
//                            }
//                        }
//                    }
//                    
//                    // Button to create a new dish
//                    if viewModel.filteredDishes.isEmpty || viewModel.searchText.isEmpty {
//                        Button(action: {
//                            viewModel.showNewDishForm = true
//                        }) {
//                            Text("Create New Dish")
//                                .fontWeight(.semibold)
//                                .foregroundColor(.white)
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(Color.blue)
//                                .cornerRadius(10)
//                        }
//                        .padding()
//                    }
//                }
//                
//                if viewModel.isLoading {
//                    ProgressView()
//                        .scaleEffect(1.5)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .background(Color.black.opacity(0.3))
//                }
//            }
//            .navigationTitle("Assign to Dish")
//            .alert(isPresented: $viewModel.showError) {
//                Alert(
//                    title: Text("Error"),
//                    message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
//            .alert(isPresented: $viewModel.showSuccess) {
//                Alert(
//                    title: Text("Success"),
//                    message: Text(viewModel.successMessage ?? "Operation completed successfully"),
//                    dismissButton: .default(Text("OK")) {
//                        presentationMode.wrappedValue.dismiss()
//                    }
//                )
//            }
//            .sheet(isPresented: $viewModel.showNewDishForm) {
//                NewDishFormView(
//                    viewModel: viewModel,
//                    restaurantId: restaurantId,
//                    modelId: modelId,
//                    uploadedBy: uploadedBy
//                )
//            }
//            .onAppear {
//                viewModel.fetchRestaurantModels(restaurantId: restaurantId)
//            }
//        }
//    }
//}
//
//struct NewDishFormView: View {
//    @ObservedObject var viewModel: ModelAssignmentViewModel
//    let restaurantId: String
//    let modelId: String
//    let uploadedBy: String
//    
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Dish Information")) {
//                    TextField("Dish Name", text: $viewModel.newDishName)
//                    
//                    TextField("Description", text: $viewModel.newDishDescription)
//                        .lineLimit(3)
//                    
//                    TextField("Ingredients", text: $viewModel.newDishIngredients)
//                        .lineLimit(3)
//                    
//                    TextField("Price", text: $viewModel.newDishPrice)
//                        .keyboardType(.decimalPad)
//                }
//                
//                Section(header: Text("Additional Information")) {
//                    TextField("Nutritional Info", text: $viewModel.newDishNutritionalInfo)
//                        .lineLimit(3)
//                    
//                    TextField("Allergens", text: $viewModel.newDishAllergens)
//                        .lineLimit(2)
//                }
//                
//                Section {
//                    Button(action: {
//                        viewModel.addNewDishWithModel(
//                            restaurantId: restaurantId,
//                            modelId: modelId,
//                            uploadedBy: uploadedBy
//                        )
//                        presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Text("Create Dish")
//                            .fontWeight(.semibold)
//                            .frame(maxWidth: .infinity)
//                    }
//                    .disabled(viewModel.newDishName.isEmpty || viewModel.newDishPrice.isEmpty)
//                }
//            }
//            .navigationTitle("New Dish")
//            .navigationBarItems(
//                trailing: Button("Cancel") {
//                    presentationMode.wrappedValue.dismiss()
//                }
//            )
//        }
//    }
//}
//
//// Usage example:
////struct ModelAssignmentViewPreview: PreviewProvider {
////    static var previews: some View {
////        ModelAssignmentView(
////            restaurantId: "ChIJ92rcyJWDRoYRotK6QCjsFf8",
////            modelId: "model456",
////            uploadedBy: "1"  // Changed to a string that can be converted to an integer
////        )
////    }
////}


//
//  ModelAssignmentView.swift
//  MenuVision
//
//  Created by Spencer Le on 4/9/25.
//

import SwiftUI
import Combine

struct DishModel: Identifiable, Hashable, Decodable {
    let dish_id: Int
    let dish_name: String
    let description: String?
    let ingredients: String?
    let price: String
    let nutritional_info: String?
    let allergens: String?
    let model_id: String
    let model_rating: Int

    var id: Int { dish_id }

    func hash(into hasher: inout Hasher) {
        hasher.combine(dish_id)
        hasher.combine(model_id)
    }

    static func == (lhs: DishModel, rhs: DishModel) -> Bool {
        return lhs.dish_id == rhs.dish_id && lhs.model_id == rhs.model_id
    }
}

struct RestaurantModels: Decodable {
    let restaurant_id: String
    let name: String
    let created_at: String
    let models: [DishModel]
}

class ModelAssignmentViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var dishes: [DishModel] = []
    @Published var filteredDishes: [DishModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var newDishName = ""
    @Published var newDishDescription = ""
    @Published var newDishIngredients = ""
    @Published var newDishPrice = ""
    @Published var newDishNutritionalInfo = ""
    @Published var newDishAllergens = ""
    @Published var showNewDishForm = false
    @Published var successMessage: String?
    @Published var showSuccess = false

    // Track whether a confirmation is needed
    @Published var needsConfirmation = false
    @Published var selectedDish: DishModel?

    // Store the modelId and uploadedBy values
    var currentModelId: String?
    var currentUploadedBy: String?

    private var cancellables = Set<AnyCancellable>()

    init() {}

    func fetchRestaurantModels(restaurantId: String) {
        isLoading = true
        errorMessage = nil

        guard let url = URL(
            string:
                "https://menu-vision-b202af7ea787.herokuapp.com/ar/restaurant/\(restaurantId)/models"
        ) else {
            self.errorMessage = "Invalid URL"
            self.showError = true
            self.isLoading = false
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                guard let response = output.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode)
                else {
                    throw URLError(.badServerResponse)
                }
                print(
                    "Raw JSON: \(String(data: output.data, encoding: .utf8) ?? "Could not convert to string")"
                )
                return output.data
            }
            .decode(type: RestaurantModels.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false

                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        if let urlError = error as? URLError {
                            self?.errorMessage = "Network error: \(urlError.localizedDescription)"
                        } else {
                            self?.errorMessage = "Decoding error: \(error.localizedDescription)"
                        }
                        self?.showError = true
                        print("Error: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    // Create a Set to store unique dish names
                    var uniqueDishNames = Set<String>()
                    var uniqueDishes: [DishModel] = []

                    // Iterate through the models and only add dishes with unique names
                    for dish in response.models {
                        if !uniqueDishNames.contains(dish.dish_name) {
                            uniqueDishNames.insert(dish.dish_name)
                            uniqueDishes.append(dish)
                        }
                    }

                    // Update the dishes array with the unique dishes
                    self?.dishes = uniqueDishes
                    self?.filterDishes(searchText: self?.searchText ?? "")
                }
            )
            .store(in: &cancellables)
    }

    func filterDishes(searchText: String) {
        if searchText.isEmpty {
            filteredDishes = dishes
        } else {
            filteredDishes = dishes.filter { dish in
                dish.dish_name.lowercased().contains(searchText.lowercased())
            }
        }
    }

    func addModelToExistingDish(dishId: Int, modelId: String, uploadedBy: String) {
        isLoading = true
        errorMessage = nil

        guard let url = URL(
            string:
                "https://menu-vision-b202af7ea787.herokuapp.com/ar/dish/\(dishId)/add_model"
        ) else {
            self.errorMessage = "Invalid URL"
            self.showError = true
            self.isLoading = false
            return
        }

        let uploadedById = Int(uploadedBy) ?? 1

        let parameters: [String: Any] = [
            "model_id": modelId,
            "uploaded_by": uploadedById,
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            self.errorMessage = "Failed to encode parameters"
            self.showError = true
            self.isLoading = false
            return
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                guard let response = output.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode)
                else {
                    throw URLError(.badServerResponse)
                }
                print(
                    "Response: \(String(data: output.data, encoding: .utf8) ?? "Could not convert to string")"
                )
                return output.data
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    switch completion {
                    case .finished:
                        self?.successMessage = "Model successfully added to dish"
                        self?.showSuccess = true
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    func addNewDishWithModel(restaurantId: String, modelId: String, uploadedBy: String) {
        if newDishPrice.isEmpty {
            errorMessage = "Price is required"
            showError = true
            return
        }

        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/ar/dish_with_model") else {
            self.errorMessage = "Invalid URL"
            self.showError = true
            self.isLoading = false
            return
        }

        let uploadedById = Int(uploadedBy) ?? 1

        let parameters: [String: Any] = [
            "restaurant_id": restaurantId,
            "dish_name": newDishName,
            "description": newDishDescription,
            "ingredients": newDishIngredients,
            "price": newDishPrice,
            "nutritional_info": newDishNutritionalInfo,
            "allergens": newDishAllergens,
            "model_id": modelId,
            "uploaded_by": uploadedById,
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            self.errorMessage = "Failed to encode parameters"
            self.showError = true
            self.isLoading = false
            return
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                guard let response = output.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode)
                else {
                    throw URLError(.badServerResponse)
                }
                print(
                    "Response: \(String(data: output.data, encoding: .utf8) ?? "Could not convert to string")"
                )
                return output.data
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    switch completion {
                    case .finished:
                        self?.resetNewDishForm()
                        self?.successMessage = "New dish created successfully"
                        self?.showSuccess = true
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    private func resetNewDishForm() {
        newDishName = ""
        newDishDescription = ""
        newDishIngredients = ""
        newDishPrice = ""
        newDishNutritionalInfo = ""
        newDishAllergens = ""
        showNewDishForm = false
    }

    func confirmAddModelToDish() {
        guard let dish = selectedDish,
              let modelId = currentModelId,
              let uploadedBy = currentUploadedBy else {
            // Handle the case where selectedDish, modelId, or uploadedBy is nil
            errorMessage = "Unable to add model to dish"
            showError = true
            needsConfirmation = false
            selectedDish = nil
            return
        }

        // Call the function to add model to dish
        addModelToExistingDish(dishId: dish.dish_id, modelId: modelId, uploadedBy: uploadedBy)

        // Reset the state
        needsConfirmation = false
        selectedDish = nil
        currentModelId = nil
        currentUploadedBy = nil
    }

    func handleDishSelection(dish: DishModel, modelId: String, uploadedBy: String) {
        // Store the modelId and uploadedBy values
        currentModelId = modelId
        currentUploadedBy = uploadedBy
        
        needsConfirmation = true
        selectedDish = dish
    }
}

struct ModelAssignmentView: View {
    @StateObject private var viewModel = ModelAssignmentViewModel()
    let restaurantId: String
    let modelId: String
    let uploadedBy: String

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Search bar
                    TextField("Search for a dish", text: $viewModel.searchText)
                        .onChange(of: viewModel.searchText) { newValue in
                            viewModel.filterDishes(searchText: newValue)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    // No results view with option to create new dish
                    if viewModel.filteredDishes.isEmpty && !viewModel.searchText.isEmpty {
                        VStack(spacing: 20) {
                            Text("No dishes found matching '\(viewModel.searchText)'")
                                .foregroundColor(.secondary)

                            Button(action: {
                                viewModel.newDishName = viewModel.searchText
                                viewModel.showNewDishForm = true
                            }) {
                                Text("Create new dish: \(viewModel.searchText)")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 30)
                    } else {
                        // List of dishes
                        List(viewModel.filteredDishes) { dish in
                            Button(action: {
                                viewModel.handleDishSelection(dish: dish, modelId: modelId, uploadedBy: uploadedBy)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(dish.dish_name)
                                        .font(.headline)

                                    if let description = dish.description, !description.isEmpty {
                                        Text(description)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }

                                    Text("$\(dish.price)")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }

                    // Removed the standalone "Create New Dish" button
                }

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .navigationTitle("Assign to Dish")
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $viewModel.showSuccess) {
                Alert(
                    title: Text("Success"),
                    message: Text(viewModel.successMessage ?? "Operation completed successfully"),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .sheet(isPresented: $viewModel.showNewDishForm) {
                NewDishFormView(
                    viewModel: viewModel,
                    restaurantId: restaurantId,
                    modelId: modelId,
                    uploadedBy: uploadedBy
                )
            }
            .alert(isPresented: $viewModel.needsConfirmation) {
                Alert(
                    title: Text("Confirm Add Model"),
                    message: Text("The dish \"\(viewModel.selectedDish?.dish_name ?? "")\" already has an AR model. Do you want to add another AR Model to this dish?"),
                    primaryButton: .destructive(Text("Cancel")),
                    secondaryButton: .default(
                        Text("Confirm")
                    ) {
                        viewModel.confirmAddModelToDish()
                    }
                )
            }
            .onAppear {
                viewModel.fetchRestaurantModels(restaurantId: restaurantId)
            }
        }
    }
}

struct NewDishFormView: View {
    @ObservedObject var viewModel: ModelAssignmentViewModel
    let restaurantId: String
    let modelId: String
    let uploadedBy: String

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dish Information")) {
                    TextField("Dish Name", text: $viewModel.newDishName)

                    TextField("Description", text: $viewModel.newDishDescription)
                        .lineLimit(3)

                    TextField("Ingredients", text: $viewModel.newDishIngredients)
                        .lineLimit(3)

                    TextField("Price", text: $viewModel.newDishPrice)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Additional Information")) {
                    TextField("Nutritional Info", text: $viewModel.newDishNutritionalInfo)
                        .lineLimit(3)

                    TextField("Allergens", text: $viewModel.newDishAllergens)
                        .lineLimit(2)
                }

                Section {
                    Button(action: {
                        viewModel.addNewDishWithModel(
                            restaurantId: restaurantId,
                            modelId: modelId,
                            uploadedBy: uploadedBy
                        )
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Create Dish")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.newDishName.isEmpty || viewModel.newDishPrice.isEmpty)
                }
            }
            .navigationTitle("New Dish")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct ModelAssignmentViewPreview: PreviewProvider {
    static var previews: some View {
        ModelAssignmentView(
            restaurantId: "ChIJ92rcyJWDRoYRotK6QCjsFf8",
            modelId: "model456",
            uploadedBy: "1"
        )
    }
}
