//
//  PostRowView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI
import Kingfisher

struct PublicPostRowView: View {
    @ObservedObject var viewModel: PublicPostRowViewModel
    @State private var hasInteracted: Bool = false
    
    let imageUrl: String = "https://fakeimg.pl/600x400"
    
    init(publicPost: PublicPost) {
        self.viewModel = PublicPostRowViewModel(publicPost: publicPost)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let user = self.viewModel.publicPost.user {
                HStack(alignment: .center, spacing: 12) {
                    KFImage(URL(string: user.avatarUrl))
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color("primaryButton"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.fullname)
                            .font(.headline).bold()
                            .foregroundColor(Color("headerText"))
                    }
                }
                
                Text(self.viewModel.publicPost.caption)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 8)
                
                VStack(spacing: 8) {
                    KFImage(URL(string: imageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .clipped()
                }
                .padding(.top, 16)
                
                buttonsView
                
                Divider()
            }
        }
        .padding()
    }
}

extension PublicPostRowView {
    var buttonsView: some View {
        HStack {
            Button {
                viewModel.publicPost.didLike ?? false ? viewModel.unlikePost() : viewModel.likePost()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: viewModel.publicPost.didLike ?? false ? "heart.fill" : "heart")
                        .font(.subheadline)
                        .foregroundColor(viewModel.publicPost.didLike ?? false ? .red : .gray)
                    
                    Text("\(viewModel.publicPost.likes)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            NavigationLink(destination: CommentsView(publicPost: viewModel.publicPost)) {
                Image(systemName: "bubble.left")
                    .font(.subheadline)
            }
            
            Spacer()
            
            Button {
                // Action for "See Challenge"
            } label: {
                Text("See Challenge")
                    .font(.subheadline)
                    .foregroundColor(Color("primaryButton"))
            }
        }
        .padding()
        .foregroundColor(.gray)
    }
}
