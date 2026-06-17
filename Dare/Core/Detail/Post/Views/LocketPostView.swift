//
//  LocketPostView.swift
//  Dare
//
//  Full-screen immersive post viewer. Photo fills the screen edge-to-edge; a bottom
//  scrim reveals the note, user info, and action buttons over the image.
//  Tapped from the TodayView circle grid via .locketPost(postId:).
//

import SwiftUI
import Kingfisher

struct LocketPostView: View {

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var postsStore: PostsStore
    @EnvironmentObject private var usersStore: UsersStore
    @Environment(\.dismiss) private var dismiss

    @State private var isLikeAnimating = false

    private let postId: String

    private var post: PublicPost? { postsStore.post(withId: postId) }
    private var user: User? {
        guard let uid = post?.uid else { return nil }
        return usersStore.user(withId: uid) ?? post?.user
    }

    init(postId: String) {
        self.postId = postId
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background photo or gradient fallback
            photoBackground
                .ignoresSafeArea()

            // Bottom scrim: transparent at top, opaque at bottom
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: UIScreen.main.bounds.height * 0.4)
                .ignoresSafeArea(edges: .bottom)
            }

            // Bottom content: user info, note, actions
            bottomOverlay

            // Top: back button
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, safeAreaTopPadding() + 8)
                Spacer()
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var photoBackground: some View {
        if let urlString = post?.imageUrls?.first, let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        } else {
            LinearGradient(
                colors: [Color("primaryButton").opacity(0.85), Color("dareBlue")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                if let emoji = post?.challenge?.emojis?.first {
                    Text(emoji).font(.system(size: 80))
                }
            }
        }
    }

    private var bottomOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info
            HStack(spacing: 8) {
                KFImage(URL(string: user?.avatarUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))

                Text(user?.username ?? "")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                if let ts = post?.timestamp {
                    Text(ts.dateValue().timeAgoSinceDate())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            // Note text
            if let note = noteText, !note.isEmpty {
                Text(note)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            // Action row
            HStack(spacing: 12) {
                likeButton
                Spacer()
                commentsButton
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, safeAreaBottomPadding() + 20)
    }

    private var noteText: String? {
        if let t = post?.title, !t.isEmpty { return t }
        if let c = post?.caption, !c.isEmpty { return c }
        return nil
    }

    private var likeButton: some View {
        Button { handleLike() } label: {
            HStack(spacing: 6) {
                Text("👏")
                    .font(.title2)
                    .scaleEffect(isLikeAnimating ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isLikeAnimating)
                Text((post?.likes ?? 0).toAbbreviatedCount())
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.white.opacity(0.15))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(post?.didLike == true)
    }

    private var commentsButton: some View {
        Button {
            guard let pid = post?.id else { return }
            router.navigate(to: .comments(postId: pid))
        } label: {
            HStack(spacing: 6) {
                Text("💬")
                Text("Comments")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.white.opacity(0.15))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func handleLike() {
        guard !(post?.didLike ?? false), !isLikeAnimating else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            isLikeAnimating = true
        }
        postsStore.likePost(postId: postId) {
            DispatchQueue.main.async { isLikeAnimating = false }
        }
    }
}
