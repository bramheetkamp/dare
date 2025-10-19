//
//  SearchUsersView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI

struct SearchUsersView: View {
    
    @EnvironmentObject private var usersStore: UsersStore
    
    var body: some View {
        SearchUsersContentView(usersStore: usersStore)
    }
    
}
