//
//  PostHeaderView.swift
//  Dare
//
//  Created by Bram Heetkamp on 18/02/2025.
//

import SwiftUI
import Kingfisher

struct PostHeaderView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var postsStore: PostsStore
    
    @State private var isLikeAnimating = false

    private let postId: String
    var post: PublicPost? {
        postsStore.post(withId: postId)
    }
    
    // MARK: - Initializer
    
    init(postId: String) {
        self.postId = postId
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color("primaryButton")
                .frame(height: 200 + safeAreaTopPadding())
                .cornerRadius(Style.CornerRadius.small, corners: [.bottomLeft, .bottomRight])
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post?.caption ?? "")
                            .font(.title2).fontWeight(.black)
                            .foregroundColor(Color.white)
                    }
                }
                .padding(.top, safeAreaTopPadding())
            }
            .padding(.leading, 16)
            .padding(.bottom, 16)
            
            // Like button
            HStack(spacing: 12) {
                InteractiveButtonStack(
                    action: {
                        handleLike()
                    },
                    cornerRadius: Style.CornerRadius.big,
                    backgroundColor: (post?.didLike ?? false) ? Color("primaryButton") : Color.gray.opacity(0.4)
                ) {
                    HStack(spacing: 8) {
                        Text("👏")
                            .font(.title2)
                            .scaleEffect(isLikeAnimating ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2), value: isLikeAnimating)
                        Text("\(post?.likes ?? 0)")
                            .font(.subheadline)
                            .foregroundColor(Color.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 20)
            .offset(y: 20)
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
    
    func safeAreaTopPadding() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
}
