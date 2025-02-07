//
//  PublicPostRowView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI
import Kingfisher

struct FeedRowView: View {
    @ObservedObject var viewModel: PublicPostRowViewModel
    @State private var hasInteracted: Bool = false

    init(publicPost: PublicPost) {
        self.viewModel = PublicPostRowViewModel(publicPost: publicPost)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let user = self.viewModel.publicPost.user {
                // User info box
                HStack(alignment: .center, spacing: 12) {
                    KFImage(URL(string: user.avatarUrl))
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.fullname)
                            .font(.subheadline).bold()
                            .foregroundColor(Color("headerText"))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundColor(Color("detailText"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color("background"))
                .cornerRadius(5)

                // Caption and image box
                VStack(alignment: .leading, spacing: 8) {
                    if !self.viewModel.publicPost.caption.isEmpty {
                        Text(self.viewModel.publicPost.caption)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 7)
                    } else {
                        Text("No caption available.")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }

                    if let imageUrl = self.viewModel.publicPost.imageUrl, !imageUrl.isEmpty {
                        KFImage(URL(string: imageUrl))
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(5)
                    }
                }
                .padding(10)
                .background(Color("background"))
                .cornerRadius(5)
            }
        }
        .padding()
        .background(Color("cell"))
        .cornerRadius(5)
    }
}
