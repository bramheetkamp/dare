//
//  CommentRowView.swift
//  Dare
//
//  Created by Bram Heetkamp on 23/01/2025.
//

import SwiftUI
import FirebaseAuth

struct CommentRowView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.uid == Auth.auth().currentUser?.uid ? "You" : (comment.user?.fullname ?? "-"))
                    .font(.headline)
                    .foregroundColor(Color("headerText"))
                Spacer()
                Text((comment.createdAt).timeAgoSinceDate())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 2)
            
            Text(comment.text)
                .font(.subheadline)
                .foregroundColor(Color("detailText"))
            
        }
        .padding()
        .background(Color("cell"))
        .cornerRadius(Style.CornerRadius.small)
    }
}
