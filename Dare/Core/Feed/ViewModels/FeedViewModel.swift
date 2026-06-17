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

    private let pageSize = 10
    private var followingUserIds: [String] = []

    var followingUserIdsList: [String] {
        return followingUserIds
    }

    private let postsStore: PostsStore
    private let usersStore: UsersStore
    private let challengesStore: ChallengesStore

    init(
        postsStore: PostsStore,
        usersStore: UsersStore,
        challengesStore: ChallengesStore
    ) {
        self.postsStore = postsStore
        self.usersStore = usersStore
        self.challengesStore = challengesStore
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
            self.followingUserIds = followingUserIds
            self.postFetchService.fetchFeedPosts(followingUserIds: followingIds, limit: self.pageSize, lastDocument: self.lastPostDocument) { newPosts, lastDoc in
                self.isLoadingPosts = false
                if newPosts.isEmpty {
                    self.hasMorePosts = false
                    return
                }

                // One batched read for all like-statuses instead of one read per post.
                let postIds = newPosts.compactMap { $0.id }
                self.postLikeService.likedPostIds(in: postIds) { likedIds in
                    var newPosts = newPosts
                    for index in newPosts.indices {
                        newPosts[index].didLike = likedIds.contains(newPosts[index].id ?? "")
                    }

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
                    // Dedup against challenges already shown to avoid repeats across pages.
                    let existingIds = Set(self.challenges.compactMap { $0.id })
                    let uniqueNew = newChallenges.filter { challenge in
                        guard let id = challenge.id else { return true }
                        return !existingIds.contains(id)
                    }
                    self.challenges.append(contentsOf: uniqueNew)
                }

                self.lastChallengeDocument = lastDoc
                self.isLoadingChallenges = false
            }
        }
    }

}
