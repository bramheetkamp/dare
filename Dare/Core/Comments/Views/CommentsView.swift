//
//  CommentsView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI

struct CommentsView: View {
    
    // MARK: - Properties
    
    let postId: String
    @StateObject private var viewModel: CommentsViewModel
    @State private var isFirstLoad = true
    
    // MARK: - Initialization
    
    init(postId: String) {
        self.postId = postId
        _viewModel = StateObject(wrappedValue: CommentsViewModel(postId: postId))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    contentView
                }
                .padding(.bottom, 80)
                .padding(.horizontal, 16)
            }
            .refreshable { refreshComments() }
            .onAppear(perform: loadInitialData)
            
            AddCommentView(viewModel: viewModel)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .withStandardPageStyle(title: "Comments", extendView: false)
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.comments.isEmpty {
            LoadingIndicatorView()
        } else if viewModel.comments.isEmpty {
            EmptyArrayMessageView(message: "No comments yet. Be the first to comment!")
        } else {
            PostCommentsView(
                comments: viewModel.comments,
                onCommentAppear: loadMoreCommentsIfNeeded
            )
        }
        
        if viewModel.isLoading && !viewModel.comments.isEmpty {
            LoadingIndicatorView()
        }
    }
    
    // MARK: - Private Helpers
    
    private func loadMoreCommentsIfNeeded(for comment: Comment) {
        guard comment.id == viewModel.comments.last?.id,
              viewModel.hasMoreComments,
              !viewModel.isLoading,
              !viewModel.comments.isEmpty
        else { return }
        
        viewModel.fetchComments()
    }
    
    private func refreshComments() {
        withAnimation {
            viewModel.resetPagination()
            viewModel.fetchComments()
        }
    }
    
    private func loadInitialData() {
        if isFirstLoad {
            viewModel.fetchComments()
            isFirstLoad = false
        }
    }
}
