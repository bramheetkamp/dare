//
//  PostContentView.swift
//  Dare
//
//  Created by Bram Heetkamp on 18/02/2025.
//

import SwiftUI
import Kingfisher

struct PostContentView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var postsStore: PostsStore
    @EnvironmentObject private var challengeStore: ChallengesStore
    
    private let postId: String
    var post: PublicPost? {
        postsStore.post(withId: postId)
    }
    
    private let challengeId: String
    var challenge: Challenge? {
        challengeStore.challenge(withId: challengeId)
    }
    
    // MARK: - Initialization
    
    init(postId: String, challengeId: String) {
        self.postId = postId
        self.challengeId = challengeId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderLabelView(text: "Content")
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if let emojis = post?.challenge?.emojis {
                        EmojiDisplaySquare(emojis: emojis, size: 30)
                    }
                    Text("Update is part of challenge")
                        .font(.caption)
                        .foregroundColor(.headerText.opacity(0.8))
                    Text(post?.challenge?.challenge ?? "-")
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundColor(.headerText)
                }
                
                Spacer()
                
                InteractiveButtonStack(
                    action: {
                        guard let challengeId = post?.challenge?.id else { return }
                        router.navigate(to: .challengeDetail(challengeId: challengeId))
                    },
                    cornerRadius: Style.CornerRadius.small,
                    backgroundColor: .primaryButton.opacity(0.1)
                ) {
                    HStack(spacing: 4) {
                        Text("See more")
                            .font(.footnote)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundColor(.primaryButton)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                }
            }
            .padding(16)
            .background(.cell)
            .cornerRadius(Style.CornerRadius.small)
            
            if let imageUrls = post?.imageUrls, let videoUrls = post?.videoUrls {
                let hasImages = !imageUrls.isEmpty
                let hasVideos = !videoUrls.isEmpty
                
                if !hasImages && !hasVideos {
                    EmptyView()
                } else if hasImages && !hasVideos && imageUrls.count == 1 {
                    if let url = URL(string: imageUrls[0]) {
                        KFImage(url)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(Style.CornerRadius.small)
                    }
                } else if !hasImages && hasVideos && videoUrls.count == 1 {
                    if let url = URL(string: videoUrls[0]) {
                        VideoPlayerView(
                            url: url,
                            isVisible: true,
                            currentPlayerID: .constant(nil),
                            postID: post?.id ?? ""
                        )
                        .aspectRatio(CGFloat(post?.mediaAspectRatios?.first ?? (16.0 / 9.0)), contentMode: .fit)
                        .cornerRadius(Style.CornerRadius.small)
                    }
                } else {
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
            } else if let imageUrls = post?.imageUrls, !imageUrls.isEmpty {
                // No videos, only images
                if imageUrls.count == 1, let url = URL(string: imageUrls[0]) {
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(Style.CornerRadius.small)
                } else {
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
                        }
                    }
                    .frame(height: UIScreen.main.bounds.width / 3)
                }
            } else if let videoUrls = post?.videoUrls, !videoUrls.isEmpty {
                if videoUrls.count == 1, let url = URL(string: videoUrls[0]) {
                    VideoPlayerView(
                        url: url,
                        isVisible: true,
                        currentPlayerID: .constant(nil),
                        postID: post?.id ?? ""
                    )
                    .aspectRatio(CGFloat(post?.mediaAspectRatios?.first ?? (16.0 / 9.0)), contentMode: .fit)
                    .cornerRadius(Style.CornerRadius.small)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
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
            } else {
                EmptyView()
            }
        }
    }
}
