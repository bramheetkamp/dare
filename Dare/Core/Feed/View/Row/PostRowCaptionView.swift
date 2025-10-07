//
//  PostRowCaptionView.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import SwiftUI

struct PostRowCaptionView: View {
    
    @EnvironmentObject private var postsStore: PostsStore
    
    var postId: String
    var post: PublicPost? {
        postsStore.post(withId: postId)
    }
    
    init(postId: String) {
        self.postId = postId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let post = post {
                Text(post.caption.isEmpty ? "No caption available." : post.caption)
                    .font(.headline)
                    .foregroundColor(Color("headerText"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
