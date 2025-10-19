//
//  FeedViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FeedViewModel: ObservableObject {

    private let userService = UserService()
    private let postFetchService = PostFetchService()
    private let postLikeService = PostLikeService()
    private let challengeService = ChallengeService()
    private let friendService = FriendService()

    @Published var feedPostIds: [String] = []
    @Published var isLoadingPosts: Bool = false
    @Published var hasMorePosts: Bool = true
    private var lastPostDocument: DocumentSnapshot?
    var getLastPostDocument: DocumentSnapshot? {
        return lastPostDocument
    }

    @Published var challenges: [Challenge] = []
    @Published var isLoadingChallenges: Bool = false
    @Published var hasMoreChallenges: Bool = true
    private var lastChallengeDocument: DocumentSnapshot?
    var getLastChallengeDocument: DocumentSnapshot? {
        return lastChallengeDocument
    }

    private let pageSize = 5
    private var followingUserIds: [String] = []

    var followingUserIdsList: [String] {
        return followingUserIds
    }

    private let postsStore: PostsStore
    private let usersStore: UsersStore

    init(postsStore: PostsStore, usersStore: UsersStore) {
        self.postsStore = postsStore
        self.usersStore = usersStore
        fetchPosts()
    }

    // MARK: Posts

    func fetchPosts() {
        guard !isLoadingPosts, hasMorePosts else { return }
        isLoadingPosts = true

        guard let currentUserId = Auth.auth().currentUser?.uid else {
            isLoadingPosts = false
            return
        }

        friendService.fetchFollowing(currentUserId: currentUserId) { [weak self] followingUserIds in
            var followingIds = followingUserIds
            followingIds.append(currentUserId)
            guard let self = self else { return }
            self.postFetchService.fetchFeedPosts(followingUserIds: followingIds, limit: self.pageSize, lastDocument: self.lastPostDocument) { newPosts, lastDoc in
                self.isLoadingPosts = false
                if newPosts.isEmpty {
                    self.hasMorePosts = false
                    return
                }

                let group = DispatchGroup()
                var newPosts = newPosts
                for index in 0 ..< newPosts.count {
                    group.enter()
                    self.userService.fetchUser(withUid: newPosts[index].uid) { user in
                        self.postLikeService.checkIsUserLikedPost(newPosts[index]) { didLike in
                            newPosts[index].didLike = didLike
                            if let user = user {
                                self.usersStore.insertOrUpdate([user])
                            }

                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    self.postsStore.insertOrUpdate(newPosts)
                    
                    let newIds = newPosts.compactMap { $0.id }
                    self.feedPostIds.append(contentsOf: newIds.filter { !self.feedPostIds.contains($0) })
                    self.lastPostDocument = lastDoc
                    self.objectWillChange.send()

                    if newPosts.count < self.pageSize {
                        self.hasMorePosts = false
                    }
                }
            }
        }
    }

    func resetPagination() {
        feedPostIds.removeAll()
        challenges.removeAll()
        hasMorePosts = true
        lastPostDocument = nil
        hasMoreChallenges = true
        lastChallengeDocument = nil
    }

    var feedPosts: [PublicPost] {
        feedPostIds.compactMap { id in
            postsStore.posts.first(where: { $0.id == id })
        }
    }

    func posts(forFilter filter: FeedFilter) -> [PublicPost] {
        switch filter {
        case .all:
            return feedPosts
        case .friends:
            return followingUserIdsList.isEmpty ? [] : feedPosts.filter { followingUserIdsList.contains($0.uid) }
        }
    }

    // MARK: Challenges

    func fetchChallenges() {
        guard let uid = Auth.auth().currentUser?.uid, !isLoadingChallenges, hasMoreChallenges else { return }
        isLoadingChallenges = true

        challengeService.fetchChallenges(uid: uid, limit: pageSize, lastDocument: lastChallengeDocument) { [weak self] newChallenges, lastDoc in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if newChallenges.isEmpty {
                    self.hasMoreChallenges = false
                } else {
                    self.challenges.append(contentsOf: newChallenges.map { challenge in
                        return challenge
                    })
                }

                self.lastChallengeDocument = lastDoc
                self.isLoadingChallenges = false
            }
        }
    }

}
