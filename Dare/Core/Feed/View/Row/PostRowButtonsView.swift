//
//  PostRowButtonsView.swift
//  Dare
//
//  Created by Bram Heetkamp on 27/01/2025.
//

import SwiftUI

struct PostRowButtonsView: View {
    
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var postsStore: PostsStore
    @EnvironmentObject private var challengesStore: ChallengesStore
    
    @StateObject private var viewModel: PostRowChallengeViewModel
    
    @State private var isLikeAnimating = false
    
    private let postId: String
    var post: PublicPost? {
        postsStore.post(withId: postId)
    }
    
    var challengeId: String
    var challenge: Challenge? {
        challengesStore.challenge(withId: challengeId)
    }
    
    let onLikeHandlerReady: ((@escaping () -> Void) -> Void)?
    
    init(
        postId: String,
        challengeId: String,
        challengesStore: ChallengesStore,
        onLikeHandlerReady: ((@escaping () -> Void) -> Void)? = nil
    ) {
        self.postId = postId
        self.challengeId = challengeId
        self.onLikeHandlerReady = onLikeHandlerReady
        _viewModel = StateObject(wrappedValue: PostRowChallengeViewModel(
            challengeId: challengeId,
            challengesStore: challengesStore
        ))
    }
    
    var body: some View {
        VStack(spacing: 14) {
            // Likes
            InteractiveButtonStack(
                action: { handleLike() },
                cornerRadius: 36 / 2,
            ) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill((post?.didLike ?? false) ?
                                  Color("primaryButton") : Color.gray.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Text("👏")
                            .font(.title2)
                            .scaleEffect(isLikeAnimating ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2),
                                       value: isLikeAnimating)
                    }
                    .contentShape(Circle())
                    
                    Text((post?.likes ?? 0).toAbbreviatedCount())
                        .font(.subheadline)
                        .foregroundColor(Color("detailText"))
                        .frame(minWidth: 30, alignment: .center)
                }
            }
            
            // Comments
            InteractiveButtonStack(
                action: {
                    guard let postId = post?.id else { return }
                    router.navigate(to: .comments(postId: postId))
                },
                cornerRadius: 36 / 2,
            ) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Text("💬")
                            .font(.title2)
                    }
                    .contentShape(Circle())
                }
            }
            
            // See more
            InteractiveButtonStack(
                action: {
                    guard let challengeId = post?.challengeId else { return }
                    router.navigate(to: .challengeDetail(challengeId: challengeId))
                },
                cornerRadius: Style.CornerRadius.small,
            ) {
                if let emojis = viewModel.challenge?.emojis {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 36, height: 36)
                        EmojiDisplaySquare(
                            emojis: emojis,
                            size: 32
                        )
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .frame(width: 44, height: 44)
                        .background(Color("primaryButton").opacity(0.15))
                        .clipShape(Circle())
                }
            }
        }
        .onAppear {
            onLikeHandlerReady?(handleLike)
        }
    }
    
    private func handleLike() {
        guard !isLikeAnimating, (post?.didLike ?? false) == false else { return }

        HapticsManager.tap()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            isLikeAnimating = true
        }

        postsStore.likePost(postId: postId) {
            DispatchQueue.main.async {
                isLikeAnimating = false
            }
        }
    }
}
