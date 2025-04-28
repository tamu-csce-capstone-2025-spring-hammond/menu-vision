import SwiftUI

/// A view that allows users to update their age information.
///
/// This view presents a form for users to update their age and handles the API request
/// to save the changes. The view manages loading states and error handling.
struct AgeChangeView: View {
    /// The string value of the user's age displayed in the text field.
    @State private var age: String = ""
    
    /// Flag indicating whether an API request is in progress.
    @State private var isLoading = false
    
    /// Flag to show the error alert when an error occurs.
    @State private var showErrorAlert = false
    
    /// The message to display in the error alert.
    @State private var errorMessage = ""
    
    /// Environment value to dismiss the view.
    @Environment(\.presentationMode) var presentationMode
    
    /// UserStateViewModel containing the user data.
    @EnvironmentObject var vm: UserStateViewModel

    /// Custom colors used throughout the view.
    /// Primary text color for the main content.
    private let textPrimaryColor = Color(red: 31/255, green: 32/255, blue: 36/255) // #1F2024
    
    /// Secondary text color for form fields and labels.
    private let textSecondaryColor = Color(red: 47/255, green: 48/255, blue: 54/255) // #2F3036
    
    /// Color used for placeholder text in form fields.
    private let placeholderColor = Color(red: 143/255, green: 144/255, blue: 152/255) // #8F9098
    
    /// Color used for form field borders.
    private let borderColor = Color(red: 197/255, green: 198/255, blue: 204/255) // #C5C6CC
    
    /// Color used for primary action buttons.
    private let buttonColor = Color(red: 250/255, green: 162/255, blue: 107/255) // #FAA26B

    /// The body content of the view.
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background
                Color.white.edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    // Header with back button and title
                    ZStack(alignment: .center) {
                        // Back button
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(textPrimaryColor)
                            }
                            .padding(.leading, 17)

                            Spacer()
                        }

                        // Title
                        Text("Change Age")
                            .font(.system(size: 24, weight: .black))
                            .bold()
                            .foregroundColor(textPrimaryColor)
                            .padding(.top, 8)
                            .tracking(0.24)
                    }
                    .frame(height: 80)

                    // Form fields
                    VStack(spacing: 16) {
                        // Age field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Update Age")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(textSecondaryColor)

                            ZStack(alignment: .leading) {
                                if age.isEmpty {
                                    Text("age")
                                        .font(.system(size: 14))
                                        .italic()
                                        .foregroundStyle(placeholderColor)
                                }

                                TextField("", text: $age)
                                    .font(.system(size: 14))
                                    .foregroundColor(textSecondaryColor)
                                    .keyboardType(.numberPad)
                                    .onAppear {
                                        // Initialize with current user data
                                        age = String(vm.userData.age)
                                    }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(borderColor, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 50)

                    Spacer()

                    // Save button
                    Button(action: {
                        updateAge()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(buttonColor)
                                .cornerRadius(12)
                        } else {
                            Text("Save")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(buttonColor)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 370)
                    .disabled(isLoading)
                }
            }
            .frame(width: min(414, geometry.size.width))
            .frame(maxWidth: .infinity)
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    /// Updates the user's age by sending a request to the server.
    ///
    /// This method validates the age input, prepares the API request payload,
    /// and sends a PUT request to update the user's age. It handles success by
    /// updating the view model and dismissing the view, and shows an error alert
    /// on failure.
    private func updateAge() {
        // Validate input
        guard let ageValue = Int(age.trimmingCharacters(in: .whitespaces)) else {
            errorMessage = "Please enter a valid age"
            showErrorAlert = true
            return
        }
        
        // Start loading
        isLoading = true
        
        // Prepare request payload
        let userId = UserDefaults.standard.integer(forKey: "user_id")
        let payload: [String: Any] = ["age": ageValue]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            errorMessage = "Failed to prepare request data"
            showErrorAlert = true
            isLoading = false
            return
        }
        
        // Make API request
        API.shared.request(
            endpoint: "user/\(userId)",
            method: "PUT",
            body: jsonData,
            headers: ["Content-Type": "application/json"]
        ) { result in
            // Ensure UI updates happen on main thread
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    // Update view model data
                    vm.userData.age = ageValue
                    
                    // Dismiss view
                    presentationMode.wrappedValue.dismiss()
                
                case .failure(let error):
                    errorMessage = "Failed to update age: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
        }
    }
}

/// A preview provider for the AgeChangeView.
#Preview {
    AgeChangeView()
        .environmentObject(UserStateViewModel())
}
