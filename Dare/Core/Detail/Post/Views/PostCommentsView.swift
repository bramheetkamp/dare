//
//  PostCommentsView.swift
//  Dare
//
//  Created by Bram Heetkamp on 18/02/2025.
//

import SwiftUI

struct PostCommentsView: View {
    var comments: [Comment]
    var onCommentAppear: (Comment) -> Void
    
    var body: some View {
        ForEach(comments, id: \.id) { comment in
            VStack(spacing: 16) {
                CommentRowView(comment: comment)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .onAppear {
                        onCommentAppear(comment)
                    }
            }
            .padding(.bottom, 8)
        }
    }
}

