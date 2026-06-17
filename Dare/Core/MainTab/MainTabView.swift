//
//  MainTabView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI

struct MainTabView: View {
    @Binding var selectedIndex: Int
    @EnvironmentObject var authViewModel: AuthViewModel

    init(selectedIndex: Binding<Int>) {
        _selectedIndex = selectedIndex
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color("background"))
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().barTintColor = UIColor(Color("background"))
    }
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            FeedView()
                .tabItem {
                    Label("Today", systemImage: "house.fill")
                }
                .tag(0)

            ExploreView()
                .tabItem {
                    Label("Discover", systemImage: "sparkle.magnifyingglass")
                }
                .tag(1)

            if let userId = authViewModel.currentUser?.id {
                ProfileView(userId: userId)
                    .tabItem {
                        Label("You", systemImage: "person.fill")
                    }
                    .tag(2)
            }
        }
        .accentColor(Color("primaryButton"))
    }
}
