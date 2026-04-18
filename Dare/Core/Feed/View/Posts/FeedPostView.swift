//
//  FeedPostView.swift
//  Dare
//
//  Created by Bram Heetkamp on 12/02/2026.
//

import SwiftUI

struct FeedPostView: View {
    @EnvironmentObject private var postsStore: PostsStore
    @EnvironmentObject private var usersStore: UsersStore
    @EnvironmentObject private var challengesStore: ChallengesStore
    
    @State private var likeAction: (() -> Void)?
    
    var isVisible: Bool
    var showChallengeView: Bool = true
    
    private let postId: String
    private let challengeId: String
    private let userId: String
    
    let bottomInset: CGFloat
    
    init(
        postId: String,
        challengeId: String,
        userId: String,
        isVisible: Bool = true,
        showChallengeView: Bool = true,
        bottomInset: CGFloat
    ) {
        self.postId = postId
        self.challengeId = challengeId
        self.userId = userId
        self.isVisible = isVisible
        self.showChallengeView = showChallengeView
        self.bottomInset = bottomInset
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [.blue.opacity(0.9), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                PostRowContentView(postId: postId, isVisible: isVisible)
                PostRowUserView(postId: postId, userId: userId, usersStore: usersStore)
                    .background(.black.opacity(0.6))
                    .cornerRadius(10)
                Spacer()
                PostRowCaptionView(postId: postId)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20 + bottomInset)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            likeAction?()
        }
        .overlay(alignment: .bottomTrailing) {
            PostRowButtonsView(
                postId: postId,
                challengeId: challengeId,
                challengesStore: challengesStore,
                onLikeHandlerReady: { handler in
                    self.likeAction = handler
                }
            )
            .padding(.trailing, 16)
            .padding(.bottom, 90 + bottomInset)
            .foregroundStyle(.white)
        }
    }
}
