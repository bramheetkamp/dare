//
//  PostRowButtonsViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import Foundation

class PostRowButtonsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private let postId: String
    private let postsStore: PostsStore
    
    @Published var post: PublicPost?
    private let postLikeService = PostLikeService()

    // MARK: - Lifecycle
    
    init(postId: String, postsStore: PostsStore) {
        self.postId = postId
        self.postsStore = postsStore
        loadPost()
    }
    
    // MARK: - Methods
    
    func loadPost() {
        if let cached = postsStore.post(withId: postId) {
            self.post = cached
            checkIfUserLikedPost()
        }
    }
    
    func checkIfUserLikedPost() {
        guard var currentPost = post else { return }
        postLikeService.checkIsUserLikedPost(currentPost) { [weak self] didLike in
            guard let self = self else { return }
            currentPost.didLike = didLike
            DispatchQueue.main.async {
                self.post = currentPost
                self.postsStore.insertOrUpdate([currentPost])
            }
        }
    }
}
