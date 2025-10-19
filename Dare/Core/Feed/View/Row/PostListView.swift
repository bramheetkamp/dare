//
//  PostListView.swift
//  Dare
//
//  Created by Bram Heetkamp on 28/01/2025.
//

import SwiftUI

struct PostListView: View {
    
    @EnvironmentObject private var postsStore: PostsStore
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
                        userId: publicPost.uid,
                        isVisible: playerManager.currentPlayerID == publicPost.id,
                        showChallengeView: showChallengeView
                    )
                    .onAppear {
                        onPostAppear(publicPost)
                        playerManager.currentPlayerID = publicPost.id
                    }
                    .onDisappear {
                        if playerManager.currentPlayerID == publicPost.id {
                            playerManager.currentPlayerID = nil
                        }
                    }
                }
            }
        }
    }
}

