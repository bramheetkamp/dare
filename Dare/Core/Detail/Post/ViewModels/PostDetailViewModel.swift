//
//  PostDetailViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 03/02/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class PostDetailViewModel: ObservableObject {
    
    @Published var postId: String
    @Published var post: PublicPost?
    @Published var isFirstLoad = true
    
    private let userService = UserService()
    private let postFetchService = PostFetchService()
    private let postLikeService = PostLikeService()
    
    private let postsStore: PostsStore
    
    init(postId: String, postsStore: PostsStore) {
        self.postId = postId
        self.postsStore = postsStore
        loadPost()
    }
    
    func loadPost() {
        if let cached = postsStore.post(withId: postId) {
            self.post = cached
        } else {
            fetchPost()
        }
    }
    
    func fetchPost() {
        postFetchService.fetchPost(postId) { [weak self] post in
            guard let self = self, let post = post else { return }
            self.postsStore.insertOrUpdate([post])
            self.post = post
            self.checkIfUserLikedPost()
        }
    }
    
    func likePost() {
        guard let post = post else { return }
        postLikeService.likePost(post) { [weak self] in
            guard let self = self else { return }
            var updated = post
            updated.didLike = true
            updated.likes += 1
            self.postsStore.insertOrUpdate([updated])
            self.post = updated
        }
    }
    
    func checkIfUserLikedPost() {
        guard let post = post else { return }
        postLikeService.checkIsUserLikedPost(post) { [weak self] didLike in
            guard let self = self else { return }
            self.post?.didLike = didLike
        }
    }
}
