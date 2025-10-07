//
//  PostService.swift
//  Dare
//
//  Created by Bram Heetkamp on 03/10/2025.
//

import FirebaseFirestore
import FirebaseAuth

struct PostService {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()

    // Firestore references
    func postsCollection() -> CollectionReference {
        return db.collection("posts")
    }

    func postDocument(_ postId: String) -> DocumentReference {
        return postsCollection().document(postId)
    }

    func userDocument(_ uid: String) -> DocumentReference {
        return db.collection("users").document(uid)
    }

    // Save post to Firestore
    func savePostToFirestore(
        uid: String,
        challengeId: String,
        caption: String,
        location: String?,
        imageUrl: String?,
        videoUrl: String?,
        date: Date?,
        mediaAspectRatio: Float?,
        completion: @escaping (Bool) -> Void
    ) {
        var data: [String: Any] = [
            "uid": uid,
            "caption": caption.trimmingCharacters(in: .whitespacesAndNewlines),
            "challengeId": challengeId,
            "timestamp": Timestamp(date: Date()),
            "timestampUpdate": Timestamp(date: date ?? Date()),
            "location": location?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            "likes": 0
        ]

        data["imageUrl"] = imageUrl ?? ""
        data["videoUrl"] = videoUrl ?? ""
        if let aspectRatio = mediaAspectRatio {
            data["mediaAspectRatio"] = aspectRatio
        }

        postsCollection().addDocument(data: data) { error in
            if let error = error {
                print("Failed to save post: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            completion(true)
        }
    }
}

