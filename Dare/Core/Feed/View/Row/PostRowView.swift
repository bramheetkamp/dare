//
//  PostRowView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI

struct PostRowView: View {
    
    @EnvironmentObject private var postsStore: PostsStore
    @EnvironmentObject private var usersStore: UsersStore
    @EnvironmentObject private var challengesStore: ChallengesStore
    
    var isVisible: Bool
    var showChallengeView: Bool = true
    
    private let postId: String
    private let challengeId: String
    private let userId: String
    
    init(
        postId: String,
        challengeId: String,
        userId: String,
        isVisible: Bool = true,
        showChallengeView: Bool = true
    ) {
        self.postId = postId
        self.challengeId = challengeId
        self.userId = userId
        self.isVisible = isVisible
        self.showChallengeView = showChallengeView
    }
    
    var body: some View {
        VStack(spacing: 12) {
            PostRowUserView(postId: postId, userId: userId, usersStore: usersStore)
            PostRowCaptionView(postId: postId)
            if showChallengeView {
                PostRowChallengeView(challengeId: challengeId, challengesStore: challengesStore)
            }
            PostRowContentView(postId: postId, isVisible: isVisible)
            PostRowButtonsView(postId: postId, challengeId: challengeId, challengesStore: challengesStore)
        }
        .padding(16)
        .background(Color("cell"))
        .cornerRadius(Style.CornerRadius.small)
    }
}
