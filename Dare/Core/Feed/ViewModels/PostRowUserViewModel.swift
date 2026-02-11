//
//  PostRowUserViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 19/10/2025.
//

import Foundation

class PostRowUserViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private let userId: String
    private let usersStore: UsersStore
    
    @Published var user: User?
    private let userService = UserService()

    // MARK: - Lifecycle
    
    init(userId: String, usersStore: UsersStore) {
        self.userId = userId
        self.usersStore = usersStore
        loadUser()
    }
    
    // MARK: - Methods
    
    func loadUser() {
        if let cached = usersStore.user(withId: userId) {
            self.user = cached
        } else {
            fetchUser()
        }
    }
    
    func fetchUser() {
        userService.fetchUser(withUid: userId) { [weak self] fetchedUser in
            guard let self = self else { return }
            self.user = fetchedUser
            if let user = fetchedUser {
                self.usersStore.insertOrUpdate([user])
            }
        }
    }
    
}

