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
}

