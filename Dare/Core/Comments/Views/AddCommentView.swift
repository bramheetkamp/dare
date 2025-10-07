//
//  AddCommentView.swift
//  Dare
//
//  Created by Bram Heetkamp on 23/01/2025.
//

import SwiftUI

struct AddCommentView: View {
    @ObservedObject var viewModel: CommentsViewModel

    var body: some View {
        VStack {
            HStack(spacing: 8) {
                TextField("Add a comment...", text: $viewModel.newCommentText)
                    .padding(12)
                    .background(Color("cell"))
                    .cornerRadius(Style.CornerRadius.small)
                    .overlay(
                        RoundedRectangle(cornerRadius: Style.CornerRadius.small)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .font(.body)

                InteractiveButtonStack(
                    action: { viewModel.addComment(text: viewModel.newCommentText) },
                    cornerRadius: Style.CornerRadius.big,
                    backgroundColor: viewModel.newCommentText.isEmpty ? Color.gray.opacity(0.1) : Color("primaryButton").opacity(0.1)
                ) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: "paperplane.fill")
                            .font(.headline)
                            .foregroundColor(viewModel.newCommentText.isEmpty ? Color("primaryButton").opacity(0.4) : Color("primaryButton"))
                            .frame(width: 28, height: 28)
                    }
                    .contentShape(Circle())
                }
                .disabled(viewModel.newCommentText.isEmpty)
            }
            .padding(10)
            .background(
                Color("primaryButton")
                    .opacity(0.2)
                    .cornerRadius(Style.CornerRadius.big)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .background(Color.clear)
    }
}
