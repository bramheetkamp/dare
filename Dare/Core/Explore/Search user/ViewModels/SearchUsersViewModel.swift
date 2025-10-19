//
//  SearchUsersViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class SearchUsersViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var hasMorePosts = true
    
    // MARK: - Private Services
    
    private let userService = UserService()
    
    // MARK: - Private State
    
    private var lastDocument: DocumentSnapshot? = nil
    private let pageSize = 15
    private let usersStore: UsersStore
    
    init(usersStore: UsersStore) {
        self.usersStore = usersStore
    }
    
    // MARK: - Fetching Users
    
    func fetchUsers() {
        let currentSearch = usersStore.searchFriendsTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !currentSearch.isEmpty else {
            users.removeAll()
            lastDocument = nil
            hasMorePosts = true
            usersStore.currentFriendsTerm = ""
            isLoading = false
            return
        }
        
        if usersStore.currentFriendsTerm != currentSearch {
            users.removeAll()
            lastDocument = nil
            hasMorePosts = true
            usersStore.currentFriendsTerm = currentSearch
        }
        
        guard !isLoading, hasMorePosts else { return }
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.userService.fetchUsers(searchText: currentSearch, limit: self.pageSize, lastDocument: self.lastDocument) { [weak self] newUsers, lastDoc in
                guard let self = self else { return }
                
                if usersStore.currentFriendsTerm != currentSearch {
                    self.isLoading = false
                    return
                }
                
                if newUsers.isEmpty {
                    self.hasMorePosts = false
                } else {
                    self.users.append(contentsOf: newUsers)
                }
                
                self.lastDocument = lastDoc
                self.isLoading = false
            }
        }
    }
    
    func updateUser(_ updatedUser: User) {
        if let index = users.firstIndex(where: { $0.id == updatedUser.id }) {
            users[index] = updatedUser
            objectWillChange.send()
        }
    }
    
    
    // MARK: - Pagination Reset
    
    func resetPagination() {
        users.removeAll()
        lastDocument = nil
        hasMorePosts = true
    }
    
}
