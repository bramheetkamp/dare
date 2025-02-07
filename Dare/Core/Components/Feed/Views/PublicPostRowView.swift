//
//  PostRowView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI
import Kingfisher

struct PostRowView: View {
    @ObservedObject var viewModel: FeedRowViewModel
    @State private var rating: Double = 6.0
    @State private var hasInteracted: Bool = false
    
    let imageUrl: String = "https://fakeimg.pl/600x400"
    
    init(post: Post) {
        self.viewModel = FeedRowViewModel(post: post)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let user = self.viewModel.post.user {
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
                
                Text(self.viewModel.post.caption)
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
                    
                    if hasInteracted {
                        Text("\(Int(rating))")
                            .font(.headline)
                            .foregroundColor(Color("headerText"))
                            .padding(12)
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(2)
                    }
                    
                    Slider(value: $rating, in: 0...10, step: 1)
                        .accentColor(.red)
                        .onChange(of: rating) { newValue in
                            hasInteracted = true
                        }
                }
                .padding(.top, 16)
                
                buttonsView
                
                Divider()
            }
        }
        .padding()
    }
}

extension PostRowView {
    var buttonsView: some View {
        HStack {
            NavigationLink(destination: CommentsView(post: viewModel.post)) {
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
