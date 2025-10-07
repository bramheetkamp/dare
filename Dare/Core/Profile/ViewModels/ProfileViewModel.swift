//
//  ProfileViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    
    let userId: String
    @Published var user: User?
    @Published var posts = [PublicPost]()
    @Published var challenges = [Challenge]()
    @Published var isLoadingPosts = false
    @Published var hasMorePosts = true
    @Published var isLoadingChallenges = false
    @Published var hasMoreChallenges = true
    @Published var isFollowing = false
    
    private let userService = UserService()
    private let postFetchService = PostFetchService()
    private let friendService = FriendService()
    private let challengeService = ChallengeService()
    
    private var lastDocumentPosts: DocumentSnapshot? = nil
    private var lastDocumentChallenges: DocumentSnapshot? = nil
    private let pageSize = 5
    
    init(userId: String) {
        self.userId = userId
        fetchUser()
    }
    
    var actionButtonTitle: String {
        guard let user = user else { return "" }
        return user.isCurrentUser ? "Settings" : (isFollowing ? "Unfollow" : "Follow")
    }
    
    func fetchUser() {
        userService.fetchUser(withUid: userId) { [weak self] fetchedUser in
            guard let self = self else { return }
            self.user = fetchedUser
            
            fetchUserPosts()
            fetchUserChallenges()
            checkIfFollowing()
        }
    }
    
    func fetchUserPosts() {
        guard let uid = user?.id, !isLoadingPosts, hasMorePosts else { return }
        isLoadingPosts = true
        
        postFetchService.fetchPosts(uid: uid, limit: pageSize, lastDocument: lastDocumentPosts) { [weak self] newPosts, lastDoc in
            guard let self = self else { return }
            if newPosts.isEmpty {
                self.hasMorePosts = false
            } else {
                let postsWithUser = newPosts.map { post -> PublicPost in
                    var postWithUser = post
                    postWithUser.user = self.user
                    return postWithUser
                }
                self.posts.append(contentsOf: postsWithUser)
            }
            self.lastDocumentPosts = lastDoc
            self.isLoadingPosts = false
        }
    }
    
    func fetchUserChallenges() {
        guard let uid = user?.id, !isLoadingChallenges, hasMoreChallenges else { return }
        isLoadingChallenges = true
        
        challengeService.fetchChallenges(uid: uid, limit: pageSize, lastDocument: lastDocumentChallenges) { [weak self] newChallenges, lastDoc in
            guard let self = self else { return }
            if newChallenges.isEmpty {
                self.hasMoreChallenges = false
            } else {
                self.challenges.append(contentsOf: newChallenges)
            }
            self.lastDocumentChallenges = lastDoc
            self.isLoadingChallenges = false
        }
    }
    
    func resetPaginationPosts() {
        posts.removeAll()
        lastDocumentPosts = nil
        hasMorePosts = true
    }
    
    func resetPaginationChallenges() {
        challenges.removeAll()
        lastDocumentChallenges = nil
        hasMoreChallenges = true
    }

    func followOrUnfollowUser() {
        guard let currentUserId = Auth.auth().currentUser?.uid, let targetUserId = user?.id else { return }
        
        if isFollowing {
            friendService.unfollowUser(currentUserId: currentUserId, targetUserId: targetUserId) { [weak self] success in
                guard let self = self else { return }
                if success {
                    self.isFollowing = false
                }
            }
        } else {
            friendService.followUser(currentUserId: currentUserId, targetUserId: targetUserId) { [weak self] success in
                guard let self = self else { return }
                if success {
                    self.isFollowing = true
                }
            }
        }
    }

    private func checkIfFollowing() {
        guard let currentUserId = Auth.auth().currentUser?.uid, let targetUserId = user?.id else { return }
        
        Firestore.firestore()
            .collection("users")
            .document(currentUserId)
            .collection("following")
            .document(targetUserId)
            .getDocument { [weak self] snapshot, _ in
                guard let self = self else { return }
                self.isFollowing = snapshot?.exists ?? false
            }
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
}
