//
//  UsersStore.swift
//  Dare
//
//  Created by Bram Heetkamp on 07/10/2025.
//

import Foundation

final class UsersStore: ObservableObject {
    
    @Published private(set) var users: [User] = []
    @Published var searchFriendsTerm: String = ""
    @Published var currentFriendsTerm: String = ""
    
    private let friendService = FriendService()
    
    func insertOrUpdate(_ newUsers: [User]) {
        for user in newUsers {
            if let index = users.firstIndex(where: { $0.id == user.id }) {
                users[index] = user
            } else {
                users.append(user)
            }
        }
    }
    
    func user(withId id: String) -> User? {
        users.first(where: { $0.id == id })
    }
    
    func followFriend(userId: String, completion: @escaping () -> Void) {
        guard let index = users.firstIndex(where: { $0.id == userId }) else { completion(); return }
        let user = users[index]
        
        friendService.followUser(user) { followed in
            if followed {
                var updatedUser = user
                updatedUser.isFollowing = true
                updatedUser.followersCount = (updatedUser.followersCount ?? 0) + 1
                DispatchQueue.main.async {
                    self.users[index] = updatedUser
                    completion()
                }
            } else {
                completion()
            }
        }
    }

    func unfollowFriend(userId: String, completion: @escaping () -> Void) {
        guard let index = users.firstIndex(where: { $0.id == userId }) else { completion(); return }
        let user = users[index]
        
        friendService.unfollowUser(user) { unfollowed in
            if unfollowed {
                var updatedUser = user
                updatedUser.isFollowing = false
                updatedUser.followersCount = max(0, (updatedUser.followersCount ?? 0) - 1)
                DispatchQueue.main.async {
                    self.users[index] = updatedUser
                    completion()
                }
            } else {
                completion()
            }
        }
    }
    
}
