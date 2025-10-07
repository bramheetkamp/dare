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
    
    private let postId: String
    var post: PublicPost? {
        postsStore.post(withId: postId)
    }
    
    // MARK: - Initializer
    
    init(postId: String) {
        self.postId = postId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderLabelView(text: "Content")
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Update is part of challenge")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text(post?.challenge?.challenge ?? "-")
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }

                Spacer()

                InteractiveButtonStack(
                    action: {
                        guard let challengeId = post?.challenge?.id else { return }
                        router.navigate(to: .challengeDetail(challengeId: challengeId))
                    },
                    cornerRadius: Style.CornerRadius.small,
                    backgroundColor: Color.white.opacity(0.2)
                ) {
                    HStack(spacing: 4) {
                        Text("Show more")
                            .font(.footnote)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                }
            }
            .padding()
            .background(Color("primaryButton").opacity(0.8))
            .cornerRadius(Style.CornerRadius.small)
            
            if let imageUrl = post?.imageUrl, !imageUrl.isEmpty {
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(Style.CornerRadius.small)
            }
        }
    }
}
