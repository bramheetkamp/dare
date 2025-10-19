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
    
    @StateObject private var viewModel: SearchUsersViewModel
    @FocusState private var isSearchFocused: Bool
    @State private var isFirstLoad = true
    
    // MARK: - Initialization
    
    init(usersStore: UsersStore) {
        _viewModel = StateObject(wrappedValue: SearchUsersViewModel(usersStore: usersStore))
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                SearchBar(text: $usersStore.searchFriendsTerm, isFocused: _isSearchFocused)
                    .onChange(of: usersStore.searchFriendsTerm) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            viewModel.fetchUsers()
                        }
                    }
                
                contentView
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 80)
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
        if viewModel.isLoading && viewModel.users.isEmpty {
            UserListSkeletonView()
        }
        else if viewModel.users.isEmpty {
            EmptyArrayMessageView(message: "No users found. Try another search.")
        }
        else {
            UserListView(
                users: viewModel.users,
                onUserAppear: loadMoreUsersIfNeeded
            )
            if viewModel.isLoading {
                UserRowSkeleton()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadMoreUsersIfNeeded(for user: User) {
        guard user.id == viewModel.users.last?.id,
              viewModel.hasMorePosts,
              !viewModel.isLoading,
              !viewModel.users.isEmpty
        else { return }
        
        viewModel.fetchUsers()
    }
    
    private func handleOnAppear() {
        if isFirstLoad {
            viewModel.fetchUsers()
            isFirstLoad = false
        } else if viewModel.users.isEmpty && !viewModel.isLoading {
            viewModel.fetchUsers()
        }
    }
}
