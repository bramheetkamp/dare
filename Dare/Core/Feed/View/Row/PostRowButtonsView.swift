//
//  FeedRowButtonsView.swift
//  Dare
//
//  Created by Bram Heetkamp on 27/01/2025.
//

import SwiftUI

struct FeedRowButtonsView: View {
    @ObservedObject var viewModel: PublicPostRowViewModel

    var body: some View {
        HStack {
            Button {
                viewModel.publicPost.didLike ?? false ? viewModel.unlikePost() : viewModel.likePost()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.publicPost.didLike ?? false ? "heart.fill" : "heart")
                        .font(.headline) // Larger icon
                        .foregroundColor(viewModel.publicPost.didLike ?? false ? .red : .gray)

                    Text("\(viewModel.publicPost.likes)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(minWidth: 44, minHeight: 44)
                .padding(8)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)

            Spacer()
            
            NavigationLink(destination: CommentsView(publicPost: viewModel.publicPost)) {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left")
                        .font(.headline)

                    Text("Comment")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(minWidth: 44, minHeight: 44)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
}
