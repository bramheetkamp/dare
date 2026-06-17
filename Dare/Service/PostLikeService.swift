//
//  PostLikeService.swift
//  Dare
//
//  Created by Bram Heetkamp on 03/10/2025.
//

import FirebaseFirestore
import FirebaseAuth

struct PostLikeService {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()

    private func postDocument(_ postId: String) -> DocumentReference {
        return db.collection("posts").document(postId)
    }

    private func postLikesCollection(postId: String) -> CollectionReference {
        return postDocument(postId).collection("likes")
    }

    private func userDocument(_ uid: String) -> DocumentReference {
        return db.collection("users").document(uid)
    }

    private func userLikesCollection(userId: String) -> CollectionReference {
        return userDocument(userId).collection("user-likes")
    }

    func likePost(_ post: PublicPost, completion: @escaping () -> Void) {
        guard let uid = auth.currentUser?.uid,
              let postId = post.id else { return }

        let postRef = postDocument(postId)
        let postLikesRef = postLikesCollection(postId: postId).document(uid)
        let userLikesRef = userLikesCollection(userId: uid).document(postId)

        let batch = db.batch()
        batch.updateData(["likes": post.likes + 1], forDocument: postRef)
        batch.setData(["timestamp": Timestamp(date: Date())], forDocument: postLikesRef)
        batch.setData(["timestamp": Timestamp(date: Date())], forDocument: userLikesRef)

        batch.commit { error in
            if let error = error {
                print("Failed to like post: \(error.localizedDescription)")
            } else {
                completion()
            }
        }
    }

    func unlikePost(_ post: PublicPost, completion: @escaping () -> Void) {
        guard let uid = auth.currentUser?.uid,
              let postId = post.id else { return }

        let postRef = postDocument(postId)
        let postLikesRef = postLikesCollection(postId: postId).document(uid)
        let userLikesRef = userLikesCollection(userId: uid).document(postId)

        let batch = db.batch()
        batch.updateData(["likes": max(post.likes - 1, 0)], forDocument: postRef)
        batch.deleteDocument(postLikesRef)
        batch.deleteDocument(userLikesRef)

        batch.commit { error in
            if let error = error {
                print("Failed to unlike post: \(error.localizedDescription)")
            } else {
                completion()
            }
        }
    }

    func checkIsUserLikedPost(_ post: PublicPost, completion: @escaping (Bool) -> Void) {
        guard let uid = auth.currentUser?.uid,
              let postId = post.id else { return }

        postLikesCollection(postId: postId)
            .document(uid)
            .getDocument { snapshot, _ in
                completion(snapshot?.exists ?? false)
            }
    }

    /// Batched "did I like these?" check. Instead of one read per post (N reads), this queries
    /// the current user's `user-likes` subcollection in chunks of 10 (Firestore `in` limit),
    /// turning N reads into ceil(N / 10). Returns the set of liked post ids.
    func likedPostIds(in postIds: [String], completion: @escaping (Set<String>) -> Void) {
        guard let uid = auth.currentUser?.uid, !postIds.isEmpty else {
            completion([])
            return
        }

        let collection = userLikesCollection(userId: uid)
        var liked = Set<String>()
        let group = DispatchGroup()

        for start in stride(from: 0, to: postIds.count, by: 10) {
            let chunk = Array(postIds[start..<min(start + 10, postIds.count)])
            group.enter()
            collection
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { snapshot, _ in
                    snapshot?.documents.forEach { liked.insert($0.documentID) }
                    group.leave()
                }
        }

        group.notify(queue: .main) {
            completion(liked)
        }
    }
}

