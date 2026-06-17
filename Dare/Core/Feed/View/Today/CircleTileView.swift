//
//  CircleTileView.swift
//  Dare
//
//  A calm, Locket-style tile for the "Today" grid: a quick pic + short note from
//  someone in your circle. No like counts, no pressure — just a glance at what they're up to.
//

import SwiftUI
import Kingfisher

struct CircleTileView: View {
    let post: PublicPost
    @StateObject private var userVM: PostRowUserViewModel

    init(post: PublicPost, usersStore: UsersStore) {
        self.post = post
        _userVM = StateObject(wrappedValue: PostRowUserViewModel(userId: post.uid, usersStore: usersStore))
    }

    private var note: String {
        if let title = post.title, !title.isEmpty { return title }
        if let caption = post.caption, !caption.isEmpty { return caption }
        return post.challenge?.challenge ?? "Update"
    }

    private var thumbURL: URL? {
        guard let first = post.imageUrls?.first else { return nil }
        return URL(string: first)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            background
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(note)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 6) {
                    KFImage(URL(string: userVM.user?.avatarUrl ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18, height: 18)
                        .clipShape(Circle())

                    Text(userVM.user?.username ?? "")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Text(post.timestamp.dateValue().timeAgoSinceDate())
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(12)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private var background: some View {
        if let thumbURL {
            KFImage(thumbURL)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        } else {
            ZStack {
                LinearGradient(
                    colors: [Color("primaryButton").opacity(0.85), Color("dareBlue")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                if let emoji = post.challenge?.emojis?.first {
                    Text(emoji).font(.system(size: 52))
                } else if post.videoUrls?.isEmpty == false {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
