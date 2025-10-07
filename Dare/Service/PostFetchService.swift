//
//  PostFetchService.swift
//  Dare
//
//  Created by Bram Heetkamp on 03/10/2025.
//

import FirebaseFirestore

struct PostFetchService {
    
    private let db = Firestore.firestore()

    private func postsCollection() -> CollectionReference {
        return db.collection("posts")
    }
    
    private func postDocument(_ postId: String) -> DocumentReference {
        return postsCollection().document(postId)
    }

    private func fetchPostsQuery(
        query: Query,
        completion: @escaping ([PublicPost], DocumentSnapshot?) -> Void
    ) {
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                completion([], nil)
                return
            }

            guard let snapshot = snapshot else {
                print("No snapshot found")
                completion([], nil)
                return
            }

            var posts = snapshot.documents.compactMap { try? $0.data(as: PublicPost.self) }
            let group = DispatchGroup()

            for (index, post) in posts.enumerated() {
                guard let challengeId = post.challengeId else { continue }
                group.enter()
                ChallengeService().fetchChallenge(challengeId: challengeId) { challenge in
                    posts[index].challenge = challenge
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(posts, snapshot.documents.last)
            }
        }
    }

    func fetchPosts(
        limit: Int,
        lastDocument: DocumentSnapshot?,
        completion: @escaping ([PublicPost], DocumentSnapshot?) -> Void
    ) {
        var query = postsCollection()
            .order(by: "timestamp", descending: true)
            .limit(to: limit)

        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        fetchPostsQuery(query: query, completion: completion)
    }

    func fetchPosts(
        uid: String?,
        limit: Int,
        lastDocument: DocumentSnapshot?,
        completion: @escaping ([PublicPost], DocumentSnapshot?) -> Void
    ) {
        var query = postsCollection()
            .order(by: "timestamp", descending: true)
            .limit(to: limit)

        if let uid = uid {
            query = query.whereField("uid", isEqualTo: uid)
        }

        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        fetchPostsQuery(query: query, completion: completion)
    }

    func fetchPosts(
        challengeId: String?,
        limit: Int,
        lastDocument: DocumentSnapshot?,
        completion: @escaping ([PublicPost], DocumentSnapshot?) -> Void
    ) {
        var query = postsCollection()
            .order(by: "timestamp", descending: true)
            .limit(to: limit)

        if let challengeId = challengeId {
            query = query.whereField("challengeId", isEqualTo: challengeId)
        }

        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        fetchPostsQuery(query: query, completion: completion)
    }

    func fetchFeedPosts(
        followingUserIds: [String],
        limit: Int,
        lastDocument: DocumentSnapshot?,
        completion: @escaping ([PublicPost], DocumentSnapshot?) -> Void
    ) {
        let batchSize = 10
        let batches = stride(from: 0, to: followingUserIds.count, by: batchSize).map {
            Array(followingUserIds[$0..<min($0 + batchSize, followingUserIds.count)])
        }

        let group = DispatchGroup()
        var allPosts: [PublicPost] = []
        var allDocuments: [QueryDocumentSnapshot] = []
        var fetchError: Error?

        for batch in batches {
            group.enter()
            var query = postsCollection()
                .whereField("uid", in: batch)
                .order(by: "timestamp", descending: true)
                .limit(to: limit)

            if let lastDocument = lastDocument, batch == batches.first {
                query = query.start(afterDocument: lastDocument)
            }

            query.getDocuments { snapshot, error in
                if let error = error {
                    fetchError = error
                } else if let snapshot = snapshot {
                    allDocuments.append(contentsOf: snapshot.documents)
                    let posts = snapshot.documents.compactMap { try? $0.data(as: PublicPost.self) }
                    allPosts.append(contentsOf: posts)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let error = fetchError {
                print("Error fetching feed posts: \(error.localizedDescription)")
                completion([], nil)
                return
            }

            let sortedPosts = allPosts.sorted { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
            let limitedPosts = Array(sortedPosts.prefix(limit))

            let challengeGroup = DispatchGroup()
            var postsWithChallenges = limitedPosts
            for (index, post) in postsWithChallenges.enumerated() {
                guard let challengeId = post.challengeId else { continue }
                challengeGroup.enter()
                ChallengeService().fetchChallenge(challengeId: challengeId) { challenge in
                    postsWithChallenges[index].challenge = challenge
                    challengeGroup.leave()
                }
            }

            challengeGroup.notify(queue: .main) {
                let lastDoc = allDocuments.sorted { doc1, doc2 in
                    let ts1 = doc1.get("timestamp") as? Timestamp ?? Timestamp(date: Date.distantPast)
                    let ts2 = doc2.get("timestamp") as? Timestamp ?? Timestamp(date: Date.distantPast)
                    return ts1.dateValue() > ts2.dateValue()
                }.prefix(limit).last
                completion(postsWithChallenges, lastDoc)
            }
        }
    }

    func fetchPost(_ postId: String, completion: @escaping (PublicPost?) -> Void) {
        postDocument(postId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching post: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                print("Post not found")
                completion(nil)
                return
            }

            do {
                var post = try snapshot.data(as: PublicPost.self)
                guard let challengeId = post.challengeId else {
                    completion(post)
                    return
                }

                ChallengeService().fetchChallenge(challengeId: challengeId) { challenge in
                    UserService().fetchUser(withUid: post.uid) { user in
                        post.user = user
                        post.challenge = challenge
                        completion(post)
                    }
                }
            } catch {
                print("Error decoding post: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}

