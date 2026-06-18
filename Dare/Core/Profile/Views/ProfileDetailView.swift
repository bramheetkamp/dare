//
//  ProfileDetailView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI
import Kingfisher

enum ProfileFilter: String, CaseIterable {
    case posts = "Posts"
    case challenges = "Challenges"
    case trophies = "Trophies"
}

public struct ProfileDetailView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: ProfileViewModel
    @Binding var selectedFilter: ProfileFilter
    
    @State private var isFirstLoadPosts = true
    @State private var isFirstLoadChallenges = true
    @State private var currentPlayerID: String? = nil
    
    let userId: String
    
    // MARK: - Initialization
    
    init(userId: String, usersStore: UsersStore, selectedFilter: Binding<ProfileFilter>) {
        self._selectedFilter = selectedFilter
        self.userId = userId
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId, usersStore: usersStore))
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ProfileHeaderView(userId: userId)
                
                FilterView(selectedFilter: $selectedFilter)
                
                VStack(alignment: .leading, spacing: 16) {
                    if selectedFilter == .posts {
                        if viewModel.isLoadingPosts && viewModel.posts.isEmpty {
                            LoadingIndicatorView()
                        } else if viewModel.posts.isEmpty {
                            EmptyArrayMessageView(message: "No posts found.")
                        } else {
                            PostListView(
                                posts: viewModel.posts,
                                onPostAppear: loadMorePostsIfNeeded
                            )
                        }

                        if viewModel.isLoadingPosts {
                            LoadingIndicatorView()
                        }
                    } else if selectedFilter == .challenges {
                        if viewModel.isLoadingChallenges && viewModel.challenges.isEmpty {
                            LoadingIndicatorView()
                        } else if viewModel.challenges.isEmpty {
                            EmptyArrayMessageView(message: "No challenges found.")
                        } else {
                            ChallengeListView(
                                challenges: viewModel.challenges,
                                onChallengeAppear: loadMoreChallengesIfNeeded
                            )
                        }

                        if viewModel.isLoadingChallenges {
                            LoadingIndicatorView()
                        }
                    } else if selectedFilter == .trophies {
                        MasteryTrophyCaseView(
                            points: viewModel.user?.totalPoints ?? 0,
                            longestStreak: viewModel.user?.bestStreak ?? 0
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .refreshable {
            withAnimation {
                if selectedFilter == .posts {
                    viewModel.resetPaginationPosts()
                    viewModel.fetchUserPosts()
                } else if selectedFilter == .challenges {
                    viewModel.resetPaginationChallenges()
                    viewModel.fetchUserChallenges()
                }
            }
        }
        .onAppear {
            if isFirstLoadPosts {
                viewModel.fetchUserPosts()
                isFirstLoadPosts = false
            } else if viewModel.posts.isEmpty && !viewModel.isLoadingPosts {
                viewModel.fetchUserPosts()
            }
            
            if isFirstLoadChallenges {
                viewModel.fetchUserChallenges()
                isFirstLoadChallenges = false
            } else if viewModel.challenges.isEmpty && !viewModel.isLoadingChallenges {
                viewModel.fetchUserChallenges()
            }
        }
        .withStandardPageStyle()
    }
    
    private func loadMorePostsIfNeeded(for post: PublicPost) {
        guard post.id == viewModel.posts.last?.id,
              viewModel.hasMorePosts,
              !viewModel.isLoadingPosts,
              !viewModel.posts.isEmpty
        else { return }
        viewModel.fetchUserPosts()
    }
    
    private func loadMoreChallengesIfNeeded(for challenge: Challenge) {
        guard challenge.id == viewModel.challenges.last?.id,
              viewModel.hasMoreChallenges,
              !viewModel.isLoadingChallenges,
              !viewModel.challenges.isEmpty
        else { return }
        viewModel.fetchUserChallenges()
    }
}
