//
//  ChallengeDetailViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ChallengeDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var challengeId: String
    @Published var challenge: Challenge?
    @Published var posts: [PublicPost] = []
    @Published var isLoading = false
    @Published var hasMorePosts = true
    @Published var isFirstLoad = true
    
    // MARK: - Private Services
    
    private let challengeService = ChallengeService()
    private let userService = UserService()
    private let postFetchService = PostFetchService()
    
    // MARK: - Private State
    
    private var lastDocument: DocumentSnapshot? = nil
    private let pageSize = 5
    
    // MARK: - Initialization
    
    init(challengeId: String) {
        self.challengeId = challengeId
        fetchChallenge()
    }
    
    // MARK: - Methods
    
    func fetchChallenge() {
        challengeService.fetchChallenge(challengeId: challengeId) { [weak self] fetchedChallenge in
            guard let self = self else { return }
            self.challenge = fetchedChallenge
            self.fetchPosts()
        }
    }
    
    func fetchPosts() {
        guard let challenge = challenge, !isLoading, hasMorePosts else { return }
        isLoading = true
        
        postFetchService.fetchPosts(challengeId: challenge.id, limit: pageSize, lastDocument: lastDocument) { [weak self] newPosts, lastDoc in
            guard let self = self else { return }
            var updatedPosts: [PublicPost] = []
            let dispatchGroup = DispatchGroup()
            
            for var post in newPosts {
                dispatchGroup.enter()
                self.userService.fetchUser(withUid: post.uid) { user in
                    post.user = user
                    updatedPosts.append(post)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if updatedPosts.isEmpty {
                    self.hasMorePosts = false
                } else {
                    self.posts.append(contentsOf: updatedPosts)
                }
                self.lastDocument = lastDoc
                self.isLoading = false
            }
        }
    }
    
    func updatePost(_ updatedPost: PublicPost) {
        if let index = posts.firstIndex(where: { $0.id == updatedPost.id }) {
            posts[index] = updatedPost
            objectWillChange.send()
        }
    }
    
    func resetPagination() {
        posts.removeAll()
        lastDocument = nil
        hasMorePosts = true
    }
}
