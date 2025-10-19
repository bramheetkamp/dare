//
//  ProfileView.swift
//  Dare
//
//  Created by Bram Heetkamp on 14/10/2025.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var usersStore: UsersStore
    
    @State private var selectedFilter: ProfileFilter = .posts
    
    private let userId: String
    
    // MARK: - Initialization
    
    init(userId: String) {
        self.userId = userId
    }

    var body: some View {
        ProfileDetailView(userId: userId, usersStore: usersStore, selectedFilter: $selectedFilter)
    }
}
