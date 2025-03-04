//
//  TabBar.swift
//  MenuVisionUI
//
//  Created by Sam Zhou on 2/28/25.
//

import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: TabItem

    var body: some View {
        HStack {
            ForEach([TabItem.home, .profile, .add, .stats, .settings], id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    Group {
                        switch tab {
                        case .home:
                            HomeIcon(isSelected: selectedTab == tab)
                        case .profile:
                            ProfileIcon(isSelected: selectedTab == tab)
                        case .add:
                            AddIcon(isSelected: selectedTab == tab)
                        case .stats:
                            StatsIcon(isSelected: selectedTab == tab)
                        case .settings:
                            SettingsIcon(isSelected: selectedTab == tab)
                            
                        }
                    }
                }
                if tab != .settings {
                    Spacer()
                }
            }
        }
        .padding(15)
        .background(Color(.black))
        .cornerRadius(30)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}
