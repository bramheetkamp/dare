//
//  SearchUsersViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI
import FirebaseAuth

class SearchUsersViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Results for the active search term.
    @Published var users: [User] = []
    /// Friends-of-friends, shown when the search term is empty.
    @Published var suggested: [User] = []
    /// Recently viewed people, shown when the search term is empty.
    @Published var recent: [User] = []

    @Published var isLoading = false
    @Published var hasMorePosts = true

    // MARK: - Services / State

    private let userService = UserService()
    private let friendService = FriendService()
    private let usersStore: UsersStore
    private let recentSearches: RecentSearchesStore

    private let pageSize = 15
    private let maxResults = 90
    private var currentLimit = 15

    var hasQuery: Bool {
        !usersStore.searchFriendsTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(usersStore: UsersStore, recentSearches: RecentSearchesStore) {
        self.usersStore = usersStore
        self.recentSearches = recentSearches
    }

    // MARK: - Search

    func fetchUsers() {
        let currentSearch = usersStore.searchFriendsTerm.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !currentSearch.isEmpty else {
            users.removeAll()
            currentLimit = pageSize
            hasMorePosts = true
            usersStore.currentFriendsTerm = ""
            isLoading = false
            return
        }

        // New term → reset the growing-limit window.
        if usersStore.currentFriendsTerm != currentSearch {
            users.removeAll()
            currentLimit = pageSize
            hasMorePosts = true
            usersStore.currentFriendsTerm = currentSearch
        }

        guard !isLoading else { return }
        isLoading = true

        userService.searchUsers(matching: currentSearch, limit: currentLimit) { [weak self] results in
            guard let self = self else { return }
            // Discard if the term changed while in flight.
            guard self.usersStore.currentFriendsTerm == currentSearch else {
                self.isLoading = false
                return
            }
            self.users = results
            self.hasMorePosts = results.count >= self.currentLimit && self.currentLimit < self.maxResults
            self.isLoading = false
        }
    }

    /// Grows the result window. Re-queries from the start (the combined search isn't cursor-based),
    /// replacing `users` with the larger set — so no duplicates and no cursor bookkeeping.
    func loadMore() {
        guard hasQuery, hasMorePosts, !isLoading else { return }
        currentLimit = min(currentLimit + pageSize, maxResults)
        fetchUsers()
    }

    // MARK: - Empty-state content

    func loadSuggestions() {
        guard let uid = Auth.auth().currentUser?.uid, suggested.isEmpty else { return }
        friendService.fetchRecommendedFriends(currentUserId: uid) { [weak self] ids in
            self?.userService.fetchUsers(byIds: ids) { users in
                self?.suggested = users
            }
        }
    }

    func loadRecent() {
        let ids = recentSearches.userIds
        guard !ids.isEmpty else { recent = []; return }
        userService.fetchUsers(byIds: ids) { [weak self] users in
            self?.recent = users
        }
    }

    func recordVisit(_ user: User) {
        guard let id = user.id else { return }
        recentSearches.record(id)
    }

    // MARK: - Updates

    func updateUser(_ updatedUser: User) {
        if let index = users.firstIndex(where: { $0.id == updatedUser.id }) {
            users[index] = updatedUser
            objectWillChange.send()
        }
    }

    func resetPagination() {
        users.removeAll()
        currentLimit = pageSize
        hasMorePosts = true
    }
}
