//
//  PostDetailView.swift
//  Dare
//
//  Created by Bram Heetkamp on 03/02/2025.
//

import SwiftUI
import Kingfisher
import FirebaseAuth

enum PostDetailFilter: String, CaseIterable {
    case all = "All"
}

struct PostDetailView: View {
    
    // MARK: - Properties
    
    @StateObject private var postDetailViewModel: PostDetailViewModel
    @StateObject private var commentsViewModel: CommentsViewModel
    @Binding var selectedFilter: PostDetailFilter
    
    private let postId: String
    @State private var isFirstLoad = true
    
    // MARK: - Initialization
    
    init(postId: String, postsStore: PostsStore, selectedFilter: Binding<PostDetailFilter>) {
        self._selectedFilter = selectedFilter
        self.postId = postId
        _postDetailViewModel = StateObject(wrappedValue: PostDetailViewModel(postId: postId, postsStore: postsStore))
        _commentsViewModel = StateObject(wrappedValue: CommentsViewModel(postId: postId))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    PostHeaderView(postId: postId)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PostContentView(postId: postId)
                        
                        sectionHeader("Comments")
                        
                        if commentsViewModel.isLoading && commentsViewModel.comments.isEmpty {
                            LoadingIndicatorView()
                        } else if commentsViewModel.comments.isEmpty {
                            EmptyArrayMessageView(message: "No comments yet. Be the first to comment!")
                        } else {
                            PostCommentsView(comments: commentsViewModel.comments, onCommentAppear: loadMoreCommentsIfNeeded)
                        }
                        
                        if commentsViewModel.isLoading && !commentsViewModel.comments.isEmpty {
                            LoadingIndicatorView()
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 80)
                    .padding(.horizontal, 16)
                }
            }
            .refreshable { refreshComments() }
            .onAppear(perform: loadInitialData)
            
            AddCommentView(viewModel: commentsViewModel)
        }
        .withStandardPageStyle()
    }
    
    // MARK: - Private Helpers
    
    private func sectionHeader(_ text: String) -> some View {
        HeaderLabelView(text: text)
    }
    
    private func loadMoreCommentsIfNeeded(for comment: Comment) {
        guard comment.id == commentsViewModel.comments.last?.id,
              commentsViewModel.hasMoreComments,
              !commentsViewModel.isLoading,
              !commentsViewModel.comments.isEmpty
        else { return }
        
        commentsViewModel.fetchComments()
    }
    
    private func refreshComments() {
        withAnimation {
            commentsViewModel.resetPagination()
            commentsViewModel.fetchComments()
        }
    }
    
    private func loadInitialData() {
        if isFirstLoad {
            commentsViewModel.fetchComments()
            isFirstLoad = false
        } else if commentsViewModel.comments.isEmpty && !commentsViewModel.isLoading {
            commentsViewModel.fetchComments()
        }
    }
}
