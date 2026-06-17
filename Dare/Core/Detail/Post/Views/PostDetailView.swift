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
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    @StateObject private var postDetailViewModel: PostDetailViewModel
    @StateObject private var commentsViewModel: CommentsViewModel
    @Binding var selectedFilter: PostDetailFilter
    
    private let postId: String
    @State private var isFirstLoad = true
    
    // MARK: - Initialization
    
    init(postId: String, postsStore: PostsStore, selectedFilter: Binding<PostDetailFilter>) {
        self._selectedFilter = selectedFilter
        self.postId = postId
        _postDetailViewModel = StateObject(wrappedValue: PostDetailViewModel(
            postId: postId,
            postsStore: postsStore
        ))
        _commentsViewModel = StateObject(wrappedValue: CommentsViewModel(postId: postId))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    PostHeaderView(postId: postId)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        if let challengeId = postDetailViewModel.post?.challengeId {
                            PostContentView(postId: postId, challengeId: challengeId)
                        }
                        
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
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120 + (keyboard.isKeyboardVisible ? 0 : safeAreaBottomPadding()))
                }
            }
            .refreshable { refreshComments() }
            .onAppear(perform: loadInitialData)
            
            sendButton
        }
        .ignoresSafeArea(edges: .bottom)
        .withStandardPageStyle()
    }
    
    // MARK: - Private Helpers
    
    private func sectionHeader(_ text: String) -> some View {
        HeaderLabelView(text: text)
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
                CustomTextField(
                    placeholder: "Write a comment...",
                    value: $commentsViewModel.newCommentText
                )
                
                InteractiveButtonStack(
                    action: { commentsViewModel.addComment(text: commentsViewModel.newCommentText) },
                    cornerRadius: Style.CornerRadius.big,
                    backgroundColor: commentsViewModel.newCommentText.isEmpty ? Color.gray.opacity(0.1) : Color("primaryButton").opacity(0.1)
                ) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: "paperplane.fill")
                            .font(.headline)
                            .foregroundColor(commentsViewModel.newCommentText.isEmpty ? Color("primaryButton").opacity(0.4) : Color("primaryButton"))
                            .frame(width: 28, height: 28)
                    }
                    .contentShape(Circle())
                }
                .disabled(commentsViewModel.newCommentText.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, (keyboard.isKeyboardVisible ? keyboard.keyboardHeight : safeAreaBottomPadding()) + 16)
        }
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
