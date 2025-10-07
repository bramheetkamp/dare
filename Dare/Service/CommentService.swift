//
//  CommentService.swift
//  Dare
//
//  Created by Bram Heetkamp on 10/11/2024.
//

import FirebaseAuth
import FirebaseFirestore

struct CommentService {
 
    func addComment(postId: String, text: String, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["uid": uid,
                    "text": text,
                    "timestamp": Timestamp(date: Date())] as [String: Any]
        
        Firestore.firestore()
            .collection("posts")
            .document(postId)
            .collection("comments")
            .document()
            .setData(data) { error in
                if let error = error {
                    print("DEBUG: Failed to add comment to post with error .. \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                print("DEBUG: Did add comment to post..")
                completion(true)
            }
    }
    
    func fetchComments(postId: String, completion: @escaping([Comment]) -> Void) {
        Firestore.firestore().collection("posts").document(postId).collection("comments")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            let comments = documents.compactMap({ try? $0.data(as: Comment.self)})
            completion(comments)
        }
    }
    
    
    func fetchComments(postId: String, limit: Int, lastDocument: DocumentSnapshot?, completion: @escaping ([Comment], DocumentSnapshot?) -> Void) {
        var query = Firestore.firestore().collection("posts")
            .document(postId).collection("comments")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)

        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching comments: \(error.localizedDescription)")
                completion([], nil)
                return
            }

            guard let snapshot = snapshot else {
                print("No snapshot found")
                completion([], nil)
                return
            }

            let comments = snapshot.documents.compactMap { try? $0.data(as: Comment.self) }
            completion(comments, snapshot.documents.last)
        }
    }
    
}
