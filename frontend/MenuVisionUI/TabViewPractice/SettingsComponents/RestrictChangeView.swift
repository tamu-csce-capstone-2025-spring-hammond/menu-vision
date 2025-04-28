import SwiftUI

/// A view that allows users to update their dietary restrictions for personalized recommendations.
struct RestrictChangeView: View {
    /// The set of dietary restrictions selected by the user.
    @State private var selectedRestrictions: Set<String> = []
    
    /// A boolean indicating whether the app is currently processing an update.
    @State private var isLoading = false
    
    /// A boolean controlling the display of an error alert.
    @State private var showErrorAlert = false
    
    /// The error message displayed in the alert.
    @State private var errorMessage = ""
    
    /// Environment property used to dismiss the view.
    @Environment(\.presentationMode) var presentationMode
    
    /// EnvironmentObject that manages user state and preferences.
    @EnvironmentObject var vm: UserStateViewModel

    /// The list of all available dietary restrictions a user can select.
    private let dietaryRestrictions = [
        "Vegetarian",
        "Vegan",
        "Pescatarian",
        "Gluten-Free",
        "Dairy-Free",
        "Nut-Free",
        "Soy-Free",
        "Egg-Free",
        "Lactose Intolerant",
        "Halal",
        "Kosher",
        "No Beef",
        "No Pork",
        "No Red Meat",
        "Low Carb",
        "Low Sugar",
        "Low Sodium"
    ]

    /// The main body of the `RestrictChangeView`.
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Header section with back button
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Text("Update Dietary Restrictions")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(Color.titleText)
                        .kerning(0.2)
                        .padding(.top, 12)
                        .lineLimit(1)

                    Text("Choose your dietary preferences.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.subtitleText)
                        .padding(.top, 4)
                }
                .padding(.leading, 23)
                .padding(.trailing, 75)
                .padding(.top, 25)
                .frame(maxWidth: .infinity, alignment: .leading)

                // List of dietary restrictions
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        Rectangle()
                            .frame(width: 327, height: 20)
                            .opacity(0)
                            .padding(.top, 10)

                        ForEach(dietaryRestrictions, id: \.self) { restriction in
                            RestrictionItem(
                                title: restriction,
                                isSelected: selectedRestrictions.contains(restriction),
                                onTap: {
                                    toggleSelection(restriction)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }

                // Spacer
                Spacer(minLength: 10)

                // Update button
                Button(action: {
                    updateRestrictions()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .padding(.horizontal, 16)
                            .background(Color.buttonBackground)
                            .cornerRadius(12)
                    } else {
                        Text("Update")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .padding(.horizontal, 16)
                            .background(Color.buttonBackground)
                            .cornerRadius(12)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .disabled(isLoading)
            }
        }
        .background(Color.white)
        .frame(maxWidth: 480)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            // Initialize selected restrictions from UserStateViewModel
            selectedRestrictions = Set(vm.userData.food_restrictions)
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    /// Toggles selection for a given dietary restriction.
    /// - Parameter restriction: The name of the dietary restriction to toggle.
    private func toggleSelection(_ restriction: String) {
        if selectedRestrictions.contains(restriction) {
            selectedRestrictions.remove(restriction)
        } else {
            selectedRestrictions.insert(restriction)
        }
    }

    /// Updates the user's dietary restrictions by sending a request to the server.
    private func updateRestrictions() {
        isLoading = true
        
        let userId = UserDefaults.standard.integer(forKey: "user_id")
        let payload: [String: Any] = ["food_restrictions": Array(selectedRestrictions)]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            errorMessage = "Failed to prepare request data"
            showErrorAlert = true
            isLoading = false
            return
        }
        
        API.shared.request(
            endpoint: "user/\(userId)",
            method: "PUT",
            body: jsonData,
            headers: ["Content-Type": "application/json"]
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    vm.userData.food_restrictions = Array(selectedRestrictions)
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    errorMessage = "Failed to update restrictions: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
        }
    }
}

// MARK: - RestrictionItem

/// A subview representing an individual selectable dietary restriction item.
extension RestrictChangeView {
    struct RestrictionItem: View {
        /// The name of the dietary restriction.
        let title: String
        
        /// A boolean indicating whether the restriction is selected.
        let isSelected: Bool
        
        /// A closure triggered when the item is tapped.
        let onTap: () -> Void

        /// The body of the `RestrictionItem`.
        var body: some View {
            Button(action: onTap) {
                HStack(spacing: 16) {
                    Text(title)
                        .font(.system(size: 14))
                        .foregroundColor(Color.itemTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.buttonBackground)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.orangeHighlight : Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? Color.selectedBorderColor : Color.borderColor,
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isSelected ?
                        Color.black.opacity(0.25) :
                        Color.black.opacity(0.05),
                    radius: isSelected ? 4 : 1,
                    x: 0,
                    y: isSelected ? 4 : 1
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Custom Colors

/// Defines custom colors used throughout the `RestrictChangeView`.
private extension Color {
    /// Title text color.
    static let titleText = Color(red: 31/255, green: 32/255, blue: 36/255) // #1F2024
    
    /// Subtitle text color.
    static let subtitleText = Color(red: 113/255, green: 114/255, blue: 122/255) // #71727A
    
    /// Border color for unselected restriction items.
    static let borderColor = Color(red: 197/255, green: 198/255, blue: 204/255) // #C5C6CC
    
    /// Button background color.
    static let buttonBackground = Color(red: 250/255, green: 162/255, blue: 107/255) // #FAA26B
    
    /// Highlight color for selected restriction items.
    static let orangeHighlight = Color(red: 254/255, green: 215/255, blue: 170/255) // lighter orange
    
    /// Border color for selected restriction items.
    static let selectedBorderColor = Color(red: 214/255, green: 211/255, blue: 209/255) // border-stone-300
    
    /// Text color for restriction item titles.
    static let itemTextColor = Color(red: 33/255, green: 33/255, blue: 33/255) // text-neutral-800
}

/// A preview provider for `RestrictChangeView`.
#Preview {
    RestrictChangeView()
        .environmentObject(UserStateViewModel())
}
