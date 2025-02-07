//
//  FeedRowViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import Foundation

class FeedRowViewModel: ObservableObject {
    @Published var post: Post
    private let service = PostService()
    
    
    init(post: Post) {
        self.post = post
    }
    
    func likePost() {
        service.likePost(post) {
            self.post.didLike = true
        }
    }
    
    func unlikePost() {
        service.unlikePost(post) {
            self.post.didLike = false
        }
    }
    
    func checkIfUserLikedPost() {
        service.checkIsUserLikedPost(post) { didLike in
            if didLike {
                self.post.didLike = true
            }
        }
    }
}
