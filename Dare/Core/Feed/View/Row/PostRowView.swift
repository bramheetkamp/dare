//
//  PostRowView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI

struct PostRowView: View {
    
    var isVisible: Bool
    var showChallengeView: Bool = true
    
    private let postId: String
    private let userId: String
    
    init(
        postId: String,
        userId: String,
        isVisible: Bool = true,
        showChallengeView: Bool = true
    ) {
        self.postId = postId
        self.userId = userId
        self.isVisible = isVisible
        self.showChallengeView = showChallengeView
    }
    
    var body: some View {
        VStack(spacing: 12) {
            PostRowUserView(postId: postId, userId: userId)
            PostRowCaptionView(postId: postId)
            if showChallengeView {
                PostRowChallengeView(postId: postId)
            }
            PostRowContentView(postId: postId, isVisible: isVisible)
            PostRowButtonsView(postId: postId)
        }
        .padding(.vertical, 12)
        .background(Color("cell"))
        .cornerRadius(Style.CornerRadius.small)
    }
}
