//
//  PassChangeView.swift
//  MenuVision
//
//  Created by Albert Yin on 4/10/25.
//

import SwiftUI

struct PassChangeView: View {
    @State private var newPassword: String = ""
       @State private var confirmPassword: String = ""
       @Environment(\.presentationMode) var presentationMode

       // Custom colors to match the design
       private let textPrimaryColor = Color(red: 31/255, green: 32/255, blue: 36/255) // #1F2024
       private let textSecondaryColor = Color(red: 47/255, green: 48/255, blue: 54/255) // #2F3036
       private let placeholderColor = Color(red: 143/255, green: 144/255, blue: 152/255) // #8F9098
       private let borderColor = Color(red: 197/255, green: 198/255, blue: 204/255) // #C5C6CC
       private let buttonColor = Color(red: 250/255, green: 162/255, blue: 107/255) // #FAA26B

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

                           // Title - Using system font with explicit bold styling
                           Text("Change Password")
                               .font(.system(size: 24, weight: .black)) // Using .black for maximum boldness
                               .bold() // Explicit bold modifier
                               .foregroundColor(textPrimaryColor)
                               .padding(.top, 8)
                               .tracking(0.24) // Letter spacing from design
                       }
                       .frame(height: 80)

                       // Form fields
                       VStack(spacing: 16) {
                           // New Password field
                           VStack(alignment: .leading, spacing: 8) {
                               Text("New Password")
                                   .font(.system(size: 12, weight: .bold))
                                   .foregroundColor(textSecondaryColor)

                               ZStack(alignment: .leading) {
                                   if newPassword.isEmpty {
                                       // Using system font with explicit italic styling
                                       Text("New password")
                                           .font(.system(size: 14))
                                           .italic() // Explicit italic modifier
                                           .foregroundStyle(placeholderColor) // Using newer API
                                   }

                                   SecureField("", text: $newPassword)
                                       .font(.system(size: 14))
                                       .foregroundColor(textSecondaryColor)
                               }
                               .padding(.horizontal, 16)
                               .frame(height: 48)
                               .background(Color.white)
                               .overlay(
                                   RoundedRectangle(cornerRadius: 12)
                                       .stroke(borderColor, lineWidth: 1)
                               )
                           }

                           // Confirm Password field
                           VStack(alignment: .leading, spacing: 8) {
                               Text("New Password, Again")
                                   .font(.system(size: 12, weight: .bold))
                                   .foregroundColor(textSecondaryColor)

                               ZStack(alignment: .leading) {
                                   if confirmPassword.isEmpty {
                                       // Using system font with explicit italic styling
                                       Text("New password, again")
                                           .font(.system(size: 14))
                                           .italic() // Explicit italic modifier
                                           .foregroundStyle(placeholderColor) // Using newer API
                                   }

                                   SecureField("", text: $confirmPassword)
                                       .font(.system(size: 14))
                                       .foregroundColor(textSecondaryColor)
                               }
                               .padding(.horizontal, 16)
                               .frame(height: 48)
                               .background(Color.white)
                               .overlay(
                                   RoundedRectangle(cornerRadius: 12)
                                       .stroke(borderColor, lineWidth: 1)
                               )
                           }

                           // Password Tips
                           HStack {
                               VStack(alignment: .leading, spacing: 4) {
                                   Text("Password Tips:")
                                       .font(.system(size: 13, weight: .bold))
                                       .foregroundColor(placeholderColor)

                                   VStack(alignment: .leading, spacing: 2) {
                                       Text("✔️ 8 to 20 Characters")
                                           .font(.system(size: 11))
                                           .foregroundColor(placeholderColor)

                                       Text("✔️ Letters, numbers, and special characters")
                                           .font(.system(size: 11))
                                           .foregroundColor(placeholderColor)
                                   }
                               }
                               Spacer()
                           }
                           .padding(.top, 8)
                       }
                       .padding(.horizontal, 24)
                       .padding(.top, 50)

                       Spacer()

                       // Save button
                       Button(action: {
                           // Handle save action
                           print("Saving new password")
                       }) {
                           Text("Save")
                               .font(.system(size: 12, weight: .semibold))
                               .foregroundColor(.white)
                               .frame(maxWidth: .infinity)
                               .frame(height: 48)
                               .background(buttonColor)
                               .cornerRadius(12)
                       }
                       .padding(.horizontal, 24)
                       .padding(.bottom, 300)
                   }
               }
               .frame(width: min(414, geometry.size.width))
               .frame(maxWidth: .infinity)
           }
           .navigationBarHidden(true) // Hide the default navigation bar
       }
   }

#Preview {
    PassChangeView()
}

