//
//  SearchUsersContentView.swift
//  Dare
//
//  Created by Bram Heetkamp on 07/10/2025.
//

import SwiftUI

struct SearchUsersContentView: View {

    // MARK: - Properties

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var usersStore: UsersStore
    @ObservedObject private var keyboard = KeyboardResponder()

    @StateObject private var viewModel: SearchUsersViewModel
    @FocusState private var isSearchFocused: Bool
    @State private var isFirstLoad = true

    // MARK: - Initialization

    init(usersStore: UsersStore, recentSearches: RecentSearchesStore) {
        _viewModel = StateObject(wrappedValue: SearchUsersViewModel(usersStore: usersStore, recentSearches: recentSearches))
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                CustomSearchBar(text: $usersStore.searchFriendsTerm, isFocused: _isSearchFocused)
                    .onChange(of: usersStore.searchFriendsTerm) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            viewModel.fetchUsers()
                        }
                    }

                contentView
            }
            .padding(.horizontal, 16)
            .padding(.bottom, (keyboard.isKeyboardVisible ? keyboard.keyboardHeight : safeAreaBottomPadding()) + 16)
        }
        .refreshable {
            withAnimation {
                viewModel.resetPagination()
                viewModel.fetchUsers()
            }
        }
        .onAppear {
            handleOnAppear()
        }
        .withStandardPageStyle(title: "Search friends", extendView: false)
    }

    // MARK: - View Content

    @ViewBuilder
    private var contentView: some View {
        if viewModel.hasQuery {
            searchResults
        } else {
            emptyState
        }
    }

    @ViewBuilder
    private var searchResults: some View {
        if viewModel.isLoading && viewModel.users.isEmpty {
            UserListSkeletonView()
        } else if viewModel.users.isEmpty {
            EmptyArrayMessageView(message: "No users found. Try another search.")
        } else {
            UserListView(
                users: viewModel.users,
                onUserAppear: loadMoreUsersIfNeeded,
                onSelect: viewModel.recordVisit
            )
            if viewModel.isLoading {
                UserRowSkeleton()
            }
        }
    }

    /// Shown when the search box is empty: quick re-access to recent people and friend suggestions.
    @ViewBuilder
    private var emptyState: some View {
        if !viewModel.recent.isEmpty {
            section(title: "Recent", users: viewModel.recent)
        }
        if !viewModel.suggested.isEmpty {
            section(title: "Suggested for you", users: viewModel.suggested)
        }
        if viewModel.recent.isEmpty && viewModel.suggested.isEmpty {
            EmptyArrayMessageView(message: "Search for friends by name or username.")
        }
    }

    private func section(title: String, users: [User]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HeaderLabelView(text: title)
            UserListView(users: users, onSelect: viewModel.recordVisit)
        }
    }

    // MARK: - Helper Functions

    private func loadMoreUsersIfNeeded(for user: User) {
        guard user.id == viewModel.users.last?.id else { return }
        viewModel.loadMore()
    }

    private func handleOnAppear() {
        viewModel.loadRecent()
        viewModel.loadSuggestions()
        if isFirstLoad {
            viewModel.fetchUsers()
            isFirstLoad = false
        }
    }
}
