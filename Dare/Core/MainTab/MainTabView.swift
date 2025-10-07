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
                .onTapGesture {
                    self.selectedIndex = 0
                }
                .tabItem {
                    Image(systemName: "house")
                }.tag(0)
            
            ExploreView()
                .onTapGesture {
                    self.selectedIndex = 1
                }
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }.tag(1)
            
            if let userId = authViewModel.currentUser?.id {
                ProfileView(userId: userId)
                    .onTapGesture {
                        self.selectedIndex = 2
                    }
                    .tabItem {
                        Image(systemName: "person.fill")
                    }.tag(2)
            }
        }
        .accentColor(Color("primaryButton"))
    }
}
