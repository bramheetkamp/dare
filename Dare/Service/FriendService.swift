//
//  FriendService.swift
//  Dare
//
//  Created by Bram Heetkamp on 01/02/2025.
//

import FirebaseFirestore

class FriendService {
    
    // Singleton Firestore instance for reuse
    private let db = Firestore.firestore()
    
    // MARK: - Firestore Collection References
    
    private func usersCollection() -> CollectionReference {
        return db.collection("users")
    }
    
    private func userDoc(_ userId: String) -> DocumentReference {
        return usersCollection().document(userId)
    }
    
    private func followingCollection(for userId: String) -> CollectionReference {
        return userDoc(userId).collection("following")
    }
    
    private func followersCollection(for userId: String) -> CollectionReference {
        return userDoc(userId).collection("followers")
    }
    
    // MARK: - Follow User with Transaction for Consistency
    
    func followUser(currentUserId: String, targetUserId: String, completion: @escaping (Bool) -> Void) {
        let batch = db.batch()
        
        let currentUserFollowingRef = followingCollection(for: currentUserId).document(targetUserId)
        let targetUserFollowersRef = followersCollection(for: targetUserId).document(currentUserId)
        
        batch.setData([:], forDocument: currentUserFollowingRef)
        batch.setData([:], forDocument: targetUserFollowersRef)
        batch.updateData(["followingCount": FieldValue.increment(Int64(1))], forDocument: userDoc(currentUserId))
        batch.updateData(["followersCount": FieldValue.increment(Int64(1))], forDocument: userDoc(targetUserId))
        
        batch.commit { error in
            if let error = error {
                print("DEBUG: Failed to follow user with error: \(error.localizedDescription)")
                completion(false)
            } else {
                print("DEBUG: Successfully followed user.")
                completion(true)
            }
        }
    }
    
    // MARK: - Unfollow User with Transaction
    
    func unfollowUser(currentUserId: String, targetUserId: String, completion: @escaping (Bool) -> Void) {
        let batch = db.batch()
        
        let currentUserFollowingRef = followingCollection(for: currentUserId).document(targetUserId)
        let targetUserFollowersRef = followersCollection(for: targetUserId).document(currentUserId)
        
        batch.deleteDocument(currentUserFollowingRef)
        batch.deleteDocument(targetUserFollowersRef)
        batch.updateData(["followingCount": FieldValue.increment(Int64(-1))], forDocument: userDoc(currentUserId))
        batch.updateData(["followersCount": FieldValue.increment(Int64(-1))], forDocument: userDoc(targetUserId))
        
        batch.commit { error in
            if let error = error {
                print("DEBUG: Failed to unfollow user with error: \(error.localizedDescription)")
                completion(false)
            } else {
                print("DEBUG: Successfully unfollowed user.")
                completion(true)
            }
        }
    }
    
    // MARK: - Fetch Following and Followers with Pagination Support
    
    func fetchFollowing(currentUserId: String, limit: Int = 100, completion: @escaping ([String]) -> Void) {
        followingCollection(for: currentUserId)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Fetch following failed with error: \(error.localizedDescription)")
                    completion([])
                    return
                }
                let userIds = snapshot?.documents.map { $0.documentID } ?? []
                completion(userIds)
            }
    }
    
    func fetchFollowers(currentUserId: String, limit: Int = 100, completion: @escaping ([String]) -> Void) {
        followersCollection(for: currentUserId)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Fetch followers failed with error: \(error.localizedDescription)")
                    completion([])
                    return
                }
                let userIds = snapshot?.documents.map { $0.documentID } ?? []
                completion(userIds)
            }
    }
    
    // MARK: - Fetch Recommended Friends
    
    func fetchRecommendedFriends(currentUserId: String, completion: @escaping ([String]) -> Void) {
        fetchFollowing(currentUserId: currentUserId) { activeFriendIds in
            var suggestedUserIds = Set<String>()
            let dispatchGroup = DispatchGroup()
            
            for activeFriendId in activeFriendIds {
                dispatchGroup.enter()
                self.followingCollection(for: activeFriendId)
                    .getDocuments { snapshot, error in
                        if let documents = snapshot?.documents {
                            for doc in documents {
                                let suggestedId = doc.documentID
                                if !activeFriendIds.contains(suggestedId) && suggestedId != currentUserId {
                                    suggestedUserIds.insert(suggestedId)
                                }
                            }
                        }
                        dispatchGroup.leave()
                    }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(Array(suggestedUserIds))
            }
        }
    }
}
