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
    @Binding private var currentIndex: Int?
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }

    private var currentHeaderTitle: String {
        if currentIndex == 0 { return greetingMessage}
        return "Submissions"
    }
    
    init(
        postsStore: PostsStore,
        usersStore: UsersStore,
        challengesStore: ChallengesStore,
        selectedFilter: Binding<FeedFilter>,
        currentIndex: Binding<Int?>
    ) {
        _feedViewModel = StateObject(wrappedValue:
                                        FeedViewModel(
                                            postsStore: postsStore,
                                            usersStore: usersStore,
                                            challengesStore: challengesStore
                                        ))
        self._selectedFilter = selectedFilter
        self._currentIndex = currentIndex
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        FeedIntroductionView(challenges: feedViewModel.challenges,
                                             onChallengeAppear: loadMoreChallengesIfNeeded)
                        .containerRelativeFrame(.vertical)
                        .id(0)
                        
                        ForEach(
                            Array(filteredPosts().enumerated()),
                            id: \.element.id
                        ) {
                            index,
                            publicPost in
                            FeedPostView(
                                postId: publicPost.id!,
                                challengeId: publicPost.challengeId!,
                                userId: publicPost.uid,
                                isVisible: playerManager.currentPlayerID == publicPost.id,
                                showChallengeView: true,
                                bottomInset: geo.safeAreaInsets.bottom
                            )
                            .onAppear {
                                loadMorePostsIfNeeded(for: publicPost)
                            }
                            .containerRelativeFrame(.vertical)
                            .id(index + 1)
                        }
                    }
                }
                .refreshable { refreshFeed() }
                .onAppear(perform: loadInitialData)
                .onDisappear { playerManager.currentPlayerID = nil }
                .scrollIndicators(.hidden)
                .scrollTargetLayout()
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $currentIndex)
                .ignoresSafeArea()

                // Fixed header (always below the notch)
                HeaderView(title: currentHeaderTitle)
                    .padding(.top, geo.safeAreaInsets.top + 10)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(.black)
            .ignoresSafeArea()
        }
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
