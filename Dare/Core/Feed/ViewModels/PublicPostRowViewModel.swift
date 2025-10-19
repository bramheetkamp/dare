//
//  PublicPostRowViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import Foundation

class PublicPostRowViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private let postId: String
    private let postsStore: PostsStore
    
    @Published var post: PublicPost?
    
    private let service = PostService()
    private let postFetchService = PostFetchService()
    private let postLikeService = PostLikeService()

    // MARK: - Lifecycle
    
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
            self.post = post
            self.checkIfUserLikedPost()
            self.postsStore.insertOrUpdate([post])
        }
    }
    
    // MARK: - Methods
    
    func checkIfUserLikedPost() {
        guard let post = post else { return }
        postLikeService.checkIsUserLikedPost(post) { [weak self] didLike in
            guard let self = self else { return }
            self.post?.didLike = didLike
        }
    }
}
