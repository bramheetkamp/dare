//
//  PostsStore.swift
//  Dare
//
//  Created by Bram Heetkamp on 09/10/2025.
//

import Foundation

final class PostsStore: ObservableObject {
    
    @Published private(set) var posts: [PublicPost] = []
    
    private let postLikeService = PostLikeService()
    
    func insertOrUpdate(_ newPosts: [PublicPost]) {
        for post in newPosts {
            if let index = posts.firstIndex(where: { $0.id == post.id }) {
                posts[index] = post
            } else {
                posts.append(post)
            }
        }
    }
    
    func post(withId id: String) -> PublicPost? {
        posts.first(where: { $0.id == id })
    }
    
    func likePost(postId: String, completion: @escaping () -> Void) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        
        let post = posts[index]
        postLikeService.likePost(post) {
            var updatedPost = post
            updatedPost.didLike = true
            updatedPost.likes += 1
            DispatchQueue.main.async {
                self.posts[index] = updatedPost
                completion()
            }
        }
    }
}
