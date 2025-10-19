//
//  ChallengeDetailView.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import SwiftUI
import Kingfisher
import FirebaseAuth

public struct ChallengeDetailView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var router: AppRouter
    
    @StateObject private var viewModel: ChallengeDetailViewModel
    
    private let challengeId: String
    @State private var isFirstLoad = true
    
    // MARK: - Initialization
    
    init(challengeId: String) {
        self.challengeId = challengeId
        _viewModel = StateObject(wrappedValue: ChallengeDetailViewModel(challengeId: challengeId))
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ChallengeHeaderView(viewModel: viewModel)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        sectionHeader("Posts")
                        
                        if viewModel.isLoading && viewModel.posts.isEmpty {
                            LoadingIndicatorView()
                        } else if viewModel.posts.isEmpty {
                            EmptyArrayMessageView(message: "No posts yet. Add an update!")
                        } else {
                            PostListView(
                                showChallengeView: false,
                                posts: viewModel.posts,
                                onPostAppear: loadMorePostsIfNeeded
                            )
                        }
                        
                        if viewModel.isLoading && !viewModel.posts.isEmpty {
                            LoadingIndicatorView()
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120 + safeAreaBottomPadding())
                }
            }
            .refreshable { refreshPosts() }
            
            AddPostChallengeView(challengeId: challengeId)
        }
        .onAppear(perform: loadInitialData)
        .ignoresSafeArea(edges: .bottom)
        .withStandardPageStyle()
    }
    
    // MARK: - Private Helpers
    
    private func sectionHeader(_ text: String) -> some View {
        HeaderLabelView(text: text)
    }
    
    private func loadMorePostsIfNeeded(for post: PublicPost) {
        guard post.id == viewModel.posts.last?.id,
              viewModel.hasMorePosts,
              !viewModel.isLoading,
              !viewModel.posts.isEmpty
        else { return }
        
        viewModel.fetchPosts()
    }
    
    private func refreshPosts() {
        withAnimation {
            viewModel.resetPagination()
            viewModel.fetchPosts()
        }
    }
    
    private func loadInitialData() {
        if isFirstLoad {
            viewModel.fetchPosts()
            isFirstLoad = false
        } else if viewModel.posts.isEmpty && !viewModel.isLoading {
            viewModel.fetchPosts()
        }
    }
    
    func safeAreaBottomPadding() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    
}
