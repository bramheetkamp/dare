//
//  PostRowContentView.swift
//  Dare
//
//  Created by Bram Heetkamp on 28/01/2025.
//

import SwiftUI
import Kingfisher
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL
    let isVisible: Bool
    @Binding var currentPlayerID: String?
    let postID: String
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        controller.showsPlaybackControls = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        guard let player = uiViewController.player else { return }
        
        if isVisible && currentPlayerID != postID {
            currentPlayerID = postID
            player.play()
        } else if !isVisible && currentPlayerID == postID {
            player.pause()
            currentPlayerID = nil
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        uiViewController.player?.pause()
        uiViewController.player = nil
    }
}

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
            if let videoUrlString = post.videoUrl,
               let url = URL(string: videoUrlString) {
                VideoPlayerView(
                    url: url,
                    isVisible: isVisible,
                    currentPlayerID: $playerManager.currentPlayerID,
                    postID: post.id!
                )
                .padding(.horizontal, 10)
                .aspectRatio(CGFloat(post.mediaAspectRatio ?? (16.0 / 9.0)), contentMode: .fit)
                .cornerRadius(Style.CornerRadius.small)
                .onDisappear {
                    if playerManager.currentPlayerID == post.id! {
                        playerManager.currentPlayerID = nil
                    }
                }
            } else if let imageUrlString = post.imageUrl, !imageUrlString.isEmpty {
                KFImage(URL(string: imageUrlString))
                    .resizable()
                    .aspectRatio(CGFloat(post.mediaAspectRatio ?? (4.0 / 3.0)), contentMode: .fit)
                    .cornerRadius(Style.CornerRadius.small)
                    .padding(.horizontal, 10)
            } else {
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }
}
