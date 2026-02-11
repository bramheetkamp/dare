//
//  PostRowContentView.swift
//  Dare
//
//  Created by Bram Heetkamp on 28/01/2025.
//

import SwiftUI
import Kingfisher
import AVKit

struct PostRowContentView: View {
    
    @EnvironmentObject private var postsStore: PostsStore
    @EnvironmentObject private var playerManager: PlayerManager
    
    var isVisible: Bool
    var postId: String
    
    private var post: PublicPost? {
        postsStore.post(withId: postId)
    }
    
    init(postId: String, isVisible: Bool) {
        self.postId = postId
        self.isVisible = isVisible
    }
    
    var body: some View {
        if let post = post {
            let hasImages = (post.imageUrls?.isEmpty == false)
            let hasVideos = (post.videoUrls?.isEmpty == false)
            
            if !hasImages && !hasVideos {
                EmptyView()
            } else if hasImages && !hasVideos {
                if post.imageUrls!.count == 1, let url = URL(string: post.imageUrls![0]) {
                    KFImage(url)
                        .resizable()
                        .aspectRatio(CGFloat(post.mediaAspectRatios?.first ?? (4.0 / 3.0)), contentMode: .fit)
                        .cornerRadius(Style.CornerRadius.small)
                } else {
                    multipleMediaScrollView(imageUrls: post.imageUrls ?? [], videoUrls: [], aspectRatios: post.mediaAspectRatios)
                }
            } else if !hasImages && hasVideos {
                if post.videoUrls!.count == 1, let url = URL(string: post.videoUrls![0]) {
                    singleVideoView(url: url, aspectRatio: post.mediaAspectRatios?.first ?? (16.0 / 9.0))
                } else {
                    multipleMediaScrollView(imageUrls: [], videoUrls: post.videoUrls ?? [], aspectRatios: post.mediaAspectRatios)
                }
            } else {
                multipleMediaScrollView(imageUrls: post.imageUrls ?? [], videoUrls: post.videoUrls ?? [], aspectRatios: post.mediaAspectRatios)
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func singleVideoView(url: URL, aspectRatio: Float) -> some View {
        VideoPlayerView(
            url: url,
            isVisible: isVisible,
            currentPlayerID: $playerManager.currentPlayerID,
            postID: postId
        )
        .aspectRatio(CGFloat(aspectRatio), contentMode: .fit)
        .cornerRadius(Style.CornerRadius.small)
        .onDisappear {
            if playerManager.currentPlayerID == postId {
                playerManager.currentPlayerID = nil
            }
        }
    }
    
    @ViewBuilder
    private func multipleMediaScrollView(imageUrls: [String], videoUrls: [String], aspectRatios: [Float]?) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(imageUrls, id: \.self) { urlString in
                    if let url = URL(string: urlString) {
                        KFImage(url)
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                            .clipped()
                            .cornerRadius(8)
                    }
                }
                
                ForEach(videoUrls, id: \.self) { urlString in
                    if let url = URL(string: urlString) {
                        VideoThumbnailView(videoURL: url)
                            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .frame(height: UIScreen.main.bounds.width / 3)
    }
}
