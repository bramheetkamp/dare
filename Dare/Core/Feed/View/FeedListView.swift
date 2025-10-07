//
//  FeedListView.swift
//  Dare
//
//  Created by Bram Heetkamp on 27/01/2025.
//

import SwiftUI
import FirebaseAuth

struct FeedListView: View {
    
    @EnvironmentObject private var playerManager: PlayerManager
    
    @StateObject private var feedViewModel: FeedViewModel
    @State private var isFirstLoad = true
    @Binding private var selectedFilter: FeedFilter
    
    init(postsStore: PostsStore, selectedFilter: Binding<FeedFilter>) {
        _feedViewModel = StateObject(wrappedValue: FeedViewModel(postsStore: postsStore))
        self._selectedFilter = selectedFilter
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if !feedViewModel.challenges.isEmpty {
                    sectionHeader("Your challenges")
                        .padding(.horizontal, 16)
                    
                    FeedChallengeListView(
                        challenges: feedViewModel.challenges,
                        onChallengeAppear: loadMoreChallengesIfNeeded
                    )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    sectionHeader("Feed")
                    
                    if feedViewModel.isLoadingPosts && filteredPosts().isEmpty {
                        LoadingIndicatorView()
                    } else if filteredPosts().isEmpty {
                        EmptyArrayMessageView(message: "No challenges yet in your feed! Start a challenge or follow your friends to see their progress.")
                    } else {
                        PostListView(
                            posts: filteredPosts(),
                            onPostAppear: loadMorePostsIfNeeded
                        )
                    }
                    
                    if feedViewModel.isLoadingPosts && !filteredPosts().isEmpty {
                        LoadingIndicatorView()
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .withStandardPageStyle(extendView: false)
        .refreshable { refreshFeed() }
        .onAppear(perform: loadInitialData)
        .onDisappear { playerManager.currentPlayerID = nil }
    }
    
    // MARK: - Private Helpers
    
    private func sectionHeader(_ text: String) -> some View {
        HeaderLabelView(text: text)
    }
    
    private func filteredPosts() -> [PublicPost] {
        feedViewModel.posts(forFilter: selectedFilter)
    }
    
    private func loadMorePostsIfNeeded(for post: PublicPost) {
        guard post.id == filteredPosts().last?.id,
              feedViewModel.hasMorePosts,
              !feedViewModel.isLoadingPosts else { return }
        feedViewModel.fetchPosts()
    }
    
    private func loadMoreChallengesIfNeeded(for challenge: Challenge) {
        guard challenge.id == feedViewModel.challenges.last?.id,
              feedViewModel.hasMoreChallenges,
              !feedViewModel.isLoadingChallenges else { return }
        feedViewModel.fetchChallenges()
    }
    
    private func refreshFeed() {
        withAnimation {
            feedViewModel.resetPagination()
            feedViewModel.fetchPosts()
            feedViewModel.fetchChallenges()
        }
    }
    
    private func loadInitialData() {
        if isFirstLoad {
            feedViewModel.fetchPosts()
            feedViewModel.fetchChallenges()
            isFirstLoad = false
        } else {
            if filteredPosts().isEmpty {
                feedViewModel.fetchPosts()
            }
            if feedViewModel.challenges.isEmpty {
                feedViewModel.fetchChallenges()
            }
        }
    }
}
