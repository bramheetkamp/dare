//
//  PostRowUserView.swift
//  Dare
//
//  Created by Bram Heetkamp on 28/01/2025.
//

import SwiftUI
import Kingfisher

struct PostRowUserView: View {
    
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var postsStore: PostsStore
    @EnvironmentObject private var usersStore: UsersStore
    
    var postId: String
    var post: PublicPost? {
        postsStore.post(withId: postId)
    }
    
    var userId: String
    var user: User? {
        usersStore.user(withId: userId)
    }
    
    init(postId: String, userId: String) {
        self.postId = postId
        self.userId = userId
    }
    
    var body: some View {
        Button {
            guard let userId = post?.uid, !userId.isEmpty else { return }
            router.navigate(to: .profile(userId: userId))
        } label: {
            if let user = user, let post = post {
                HStack(alignment: .center, spacing: 12) {
                    KFImage(URL(string: user.avatarUrl))
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.fullname)
                            .font(.subheadline).bold()
                            .foregroundColor(Color("headerText"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                        
                        let time = post.timestamp.dateValue().timeAgoSinceDate()
                        let location = post.location.isEmpty ? "" : " - " + post.location
                        let text = "\(time)\(location)"
                        Text(text)
                            .font(.subheadline)
                            .foregroundColor(Color("detailText"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
    }
}
