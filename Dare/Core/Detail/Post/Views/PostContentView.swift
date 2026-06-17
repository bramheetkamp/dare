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
    private var post: PublicPost? { postsStore.post(withId: postId) }

    private let challengeId: String
    private var challenge: Challenge? { challengeStore.challenge(withId: challengeId) }

    // MARK: - Initialization

    init(postId: String, challengeId: String) {
        self.postId = postId
        self.challengeId = challengeId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderLabelView(text: "Content")
            challengeCard
            mediaSection
        }
    }

    // MARK: - Challenge card

    private var challengeCard: some View {
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
    }

    // MARK: - Media

    @ViewBuilder
    private var mediaSection: some View {
        let images = post?.imageUrls ?? []
        let videos = post?.videoUrls ?? []

        if images.isEmpty && videos.isEmpty {
            EmptyView()
        } else if videos.isEmpty && images.count == 1 {
            fullWidthImage(images[0])
        } else if images.isEmpty && videos.count == 1 {
            singleVideo(videos[0])
        } else {
            mediaGrid(images: images, videos: videos)
        }
    }

    @ViewBuilder
    private func fullWidthImage(_ urlString: String) -> some View {
        if let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .cornerRadius(Style.CornerRadius.small)
        }
    }

    @ViewBuilder
    private func singleVideo(_ urlString: String) -> some View {
        if let url = URL(string: urlString) {
            VideoPlayerView(
                url: url,
                isVisible: true,
                currentPlayerID: .constant(nil),
                postID: post?.id ?? ""
            )
            .aspectRatio(CGFloat(post?.mediaAspectRatios?.first ?? (16.0 / 9.0)), contentMode: .fit)
            .cornerRadius(Style.CornerRadius.small)
        }
    }

    private func mediaGrid(images: [String], videos: [String]) -> some View {
        let side = UIScreen.main.bounds.width / 3
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(images, id: \.self) { urlString in
                    if let url = URL(string: urlString) {
                        KFImage(url)
                            .resizable()
                            .scaledToFill()
                            .frame(width: side, height: side)
                            .clipped()
                            .cornerRadius(8)
                    }
                }
                ForEach(videos, id: \.self) { urlString in
                    if let url = URL(string: urlString) {
                        VideoThumbnailView(videoURL: url)
                            .frame(width: side, height: side)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .frame(height: side)
    }
}
