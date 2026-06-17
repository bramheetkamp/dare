//
//  SearchUsersView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI

struct SearchUsersView: View {
    
    @EnvironmentObject private var usersStore: UsersStore
    @EnvironmentObject private var recentSearches: RecentSearchesStore

    var body: some View {
        SearchUsersContentView(usersStore: usersStore, recentSearches: recentSearches)
    }
    
}
