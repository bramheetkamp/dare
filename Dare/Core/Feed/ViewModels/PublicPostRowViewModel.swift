//
//  PublicPostRowViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import Foundation

class PublicPostRowViewModel: ObservableObject {
    @Published var publicPost: PublicPost
    private let service = PostService()
    
    init(publicPost: PublicPost) {
        self.publicPost = publicPost
        checkIfUserLikedPost()
    }
    
    func likePost() {
        service.likePost(publicPost) {
            DispatchQueue.main.async {
                self.publicPost.didLike = true
                self.publicPost.likes += 1
            }
        }
    }
    
    func unlikePost() {
        service.unlikePost(publicPost) {
            DispatchQueue.main.async {
                self.publicPost.didLike = false
                self.publicPost.likes = max(self.publicPost.likes - 1, 0)
            }
        }
    }
    
    func checkIfUserLikedPost() {
        service.checkIsUserLikedPost(publicPost) { didLike in
            DispatchQueue.main.async {
                self.publicPost.didLike = didLike
            }
        }
    }
}
