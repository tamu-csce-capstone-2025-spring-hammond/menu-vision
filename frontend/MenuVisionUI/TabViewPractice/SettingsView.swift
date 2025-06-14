//
//  SettingsView.swift
//  MenuVision
//
//  Created by Albert Yin on 4/3/25.
//
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: UserStateViewModel
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Nav Bar
                Text("Settings")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Profile info
                        VStack(alignment: .center, spacing: 0) {
                            AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/d5fada1d8e9d21931e1e4403a0769657c2e10a73?placeholderIfAbsent=true&format=webp")) { image in image
                                    .resizable()
                                    .aspectRatio(0.99, contentMode: .fit)
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                            .frame(width: 82, height: 82)
                            VStack(alignment: .center, spacing: 4) {
                                Text(vm.userData.first_name + " " + vm.userData.last_name)
                                    .font(.system(size: 16, weight: .heavy))
                                    .tracking(-0.5)
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                
                                Text(vm.userData.email)
                                    .font(.system(size: 12))
                                    .tracking(-0.5)
                                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                                    .padding(.top, 1)
                            }
                            .padding(.top, 16)
                        }
                        .padding(.horizontal, 36)
                        .padding(.vertical, 8)
                        
                        // Settings List
                        VStack(spacing: 0) {
                            NavigationLink(destination: NameChangeView()) {
                                SettingsItemView(title: "Name", iconURL: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/6f7c5c6258ff91b32ce8094789c38f26145bb0e9?placeholderIfAbsent=true")
                            }
                            
                            Divider()
                                .padding(.horizontal, 0)
                            
//                            NavigationLink(destination: UserChangeView()) {
//                                SettingsItemView(title: "Username", iconURL: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/11a7c5f6112b6118688ced18bc061843134a4eba?placeholderIfAbsent=true")
//                            }
//                            
//                            Divider()
//                                .padding(.horizontal, 0)
                            
                            NavigationLink(destination: PassChangeView()) {
                                SettingsItemView(title: "Password", iconURL: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/e28c1c6a07eea247c30a7b352bf54c411fd89f48?placeholderIfAbsent=true")
                            }
                            
                            Divider()
                                .padding(.horizontal, 0)
                            
                            NavigationLink(destination: EmailChangeView()) {
                                SettingsItemView(title: "Email", iconURL: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/3045bece4264eeefd801db6958088265737f1fe4?placeholderIfAbsent=true")
                            }
                            
                            Divider()
                                .padding(.horizontal, 0)
                            
                            NavigationLink(destination: AgeChangeView()) {
                                SettingsItemView(title: "Age", iconURL: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/3045bece4264eeefd801db6958088265737f1fe4?placeholderIfAbsent=true")
                            }
                            
                            Divider()
                                .padding(.horizontal, 0)
                            
                            NavigationLink(destination: RestrictChangeView()) {
                                SettingsItemView(title: "Dietary Restrictions", iconURL: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/de44426ca3e8e96b92e1b42b4dd28f31fcff89f9?placeholderIfAbsent=true")
                            }
                            
                            Divider()
                                .padding(.horizontal, 0)
                            
                            NavigationLink(destination: PrefChangeView()) {
                                SettingsItemView(title: "Dietary Preferences", iconURL: "https://cdn.builder.io/api/v1/image/assets/c5b4e4c8487a42d48871ad1e7d9ecefa/40caf6b5d3f0daaad79ae5f0316b592311082ff9?placeholderIfAbsent=true")
                            }
                            
                            Divider()
                                .padding(.horizontal, 0)
                            Button(action: {
                                vm.isLoggedIn = false
                                UserDefaults.standard.set(false, forKey: "is_logged_in")
                                UserDefaults.standard.set(0, forKey: "user_id")
                                
                                
                                
                            }) {
                                Text("LOG OUT")
                                    .font(.system(size: 14, weight: .medium))
                                    .tracking(2)
                                    .foregroundColor(Color(red: 0.98, green: 0.96, blue: 0.99))
                                    .frame(width: 100)
                                    .frame(height: 40)
                                    .background(Color(red: 0.98, green: 0.67, blue: 0.48))
                                    .cornerRadius(38)
                            }
                            .padding(.top, 20)
                        }
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                        
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 24)
                    
                    Spacer(minLength: 176) // Spacer to push tab bar to bottom
                }
            }
            .navigationBarHidden(true)
            
            // Tab Bar
            TabBarView()
                .background(Color.white)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: 480)
    }
}


#Preview {
    SettingsView()
}
