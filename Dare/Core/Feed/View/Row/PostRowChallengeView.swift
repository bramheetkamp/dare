//
//  PostRowChallengeView.swift
//  Dare
//
//  Created by Bram Heetkamp on 14/06/2025.
//

import SwiftUI

struct PostRowChallengeView: View {
    
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var postsStore: PostsStore
    
    @State private var navigateToChallenge = false
    
    var postId: String
    var post: PublicPost? {
        postsStore.post(withId: postId)
    }
    
    init(postId: String) {
        self.postId = postId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
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
            .background(.secondaryButton.opacity(0.8))
            .cornerRadius(Style.CornerRadius.small)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
