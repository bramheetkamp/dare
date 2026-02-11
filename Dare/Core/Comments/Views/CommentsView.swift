//
//  CommentsView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI

struct CommentsView: View {
    
    // MARK: - Properties
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    @StateObject private var viewModel: CommentsViewModel
    @State private var isFirstLoad = true
    
    let postId: String
    
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
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 120 + (keyboard.isKeyboardVisible ? 0 : safeAreaBottomPadding()))
            }
            .refreshable { refreshComments() }
            .onAppear(perform: loadInitialData)
            
            sendButton
        }
        .ignoresSafeArea(edges: .bottom)
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
    
    @ViewBuilder
    private var sendButton: some View {
        ZStack(alignment: .bottom) {
            let baseHeight: CGFloat = 52 + 32
            let backgroundHeight = baseHeight + (keyboard.isKeyboardVisible ? keyboard.keyboardHeight : safeAreaBottomPadding())
            
            Color(.cell)
                .cornerRadius(Style.CornerRadius.small, corners: [.topLeft, .topRight])
                .frame(height: backgroundHeight)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .bottom)
            
            HStack(spacing: 8) {
                TextField("Write a comment...", text: $viewModel.newCommentText)
                    .padding(12)
                    .background(Color("cell"))
                    .cornerRadius(Style.CornerRadius.small)
                    .overlay(
                        RoundedRectangle(cornerRadius: Style.CornerRadius.small)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .font(.body)
                
                InteractiveButtonStack(
                    action: { viewModel.addComment(text: viewModel.newCommentText) },
                    cornerRadius: Style.CornerRadius.big,
                    backgroundColor: viewModel.newCommentText.isEmpty ? Color.gray.opacity(0.1) : Color("primaryButton").opacity(0.1)
                ) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: "paperplane.fill")
                            .font(.headline)
                            .foregroundColor(viewModel.newCommentText.isEmpty ? Color("primaryButton").opacity(0.4) : Color("primaryButton"))
                            .frame(width: 28, height: 28)
                    }
                    .contentShape(Circle())
                }
                .disabled(viewModel.newCommentText.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, (keyboard.isKeyboardVisible ? keyboard.keyboardHeight : safeAreaBottomPadding()) + 16)
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
    
    func safeAreaBottomPadding() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    
}
