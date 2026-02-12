//
//  PostListView.swift
//  Dare
//
//  Created by Bram Heetkamp on 28/01/2025.
//

import SwiftUI

struct PostListView: View {
    
    @EnvironmentObject var playerManager: PlayerManager
    
    var showChallengeView: Bool = true
    var posts: [PublicPost]
    var onPostAppear: (PublicPost) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 16) {
                ForEach(posts, id: \.id) { publicPost in
                    PostRowView(
                        postId: publicPost.id!,
                        challengeId: publicPost.challengeId!,
                        userId: publicPost.uid,
                        isVisible: playerManager.currentPlayerID == publicPost.id,
                        showChallengeView: showChallengeView
                    )
                    .onAppear {
                        onPostAppear(publicPost)
                    }
                }
            }
        }
    }
}
