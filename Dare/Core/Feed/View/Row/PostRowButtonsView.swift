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
    
//    @StateObject private var viewModel: PostRowButtonsViewModel
    
    @State private var isLikeAnimating = false
    
    private let postId: String
    var post: PublicPost? {
        postsStore.post(withId: postId)
    }
    
    init(postId: String) {
        self.postId = postId
    }
//        _viewModel = StateObject(wrappedValue: PostRowButtonsViewModel(
//            postId: postId,
//            postsStore: postsStore
//        ))

    var body: some View {
        HStack(spacing: 4) {
            // Likes
            InteractiveButtonStack(
                action: { handleLike() },
                cornerRadius: 36 / 2,
            ) {
                HStack(spacing: 8) {
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

                    Text("\(post?.likes ?? 0)")
                        .font(.subheadline)
                        .foregroundColor(Color("detailText"))
                        .frame(minWidth: 30, alignment: .leading)
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
                HStack(spacing: 8) {
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

            Spacer()

            // See more
            InteractiveButtonStack(
                action: {
                    guard let postId = post?.id else { return }
                    router.navigate(to: .postDetail(postId: postId))
                },
                cornerRadius: Style.CornerRadius.small,
                backgroundColor: Color("primaryButton").opacity(0.1)
            ) {
                HStack(spacing: 6) {
                    Text("See more")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundColor(Color("primaryButton"))
            }
        }
    }

    private func handleLike() {
        guard !isLikeAnimating, (post?.didLike ?? false) == false else { return }

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
