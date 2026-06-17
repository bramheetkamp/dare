//
//  FriendService.swift
//  Dare
//
//  Created by Bram Heetkamp on 01/02/2025.
//

import FirebaseFirestore
import FirebaseAuth

class FriendService {
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
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
    
    func followUser(_ user: User, completion: @escaping (Bool) -> Void) {
        guard let uid = auth.currentUser?.uid, let userId = user.id else { return }
        
        let db = Firestore.firestore()
        let currentUserRef = userDoc(uid)
        let targetUserRef = userDoc(userId)
        let currentUserFollowingRef = followingCollection(for: uid).document(userId)
        let targetUserFollowersRef = followersCollection(for: userId).document(uid)
        
        db.runTransaction { transaction, errorPointer -> Any? in
            do {
                let currentUserSnap = try transaction.getDocument(currentUserRef)
                let targetUserSnap = try transaction.getDocument(targetUserRef)
                
                let followingCount = (currentUserSnap.data()?["followingCount"] as? Int ?? 0) + 1
                let followersCount = (targetUserSnap.data()?["followersCount"] as? Int ?? 0) + 1
                
                transaction.setData([:], forDocument: currentUserFollowingRef)
                transaction.setData([:], forDocument: targetUserFollowersRef)
                transaction.updateData(["followingCount": followingCount], forDocument: currentUserRef)
                transaction.updateData(["followersCount": followersCount], forDocument: targetUserRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
            
            return nil
        } completion: { _, error in
            completion(error == nil)
        }
    }
    
    
    // MARK: - Unfollow User with Transaction
    
    func unfollowUser(_ user: User, completion: @escaping (Bool) -> Void) {
        guard let uid = auth.currentUser?.uid, let userId = user.id else { return }
        let batch = db.batch()
        
        let currentUserFollowingRef = followingCollection(for: uid).document(userId)
        let targetUserFollowersRef = followersCollection(for: userId).document(uid)
        
        batch.deleteDocument(currentUserFollowingRef)
        batch.deleteDocument(targetUserFollowersRef)
        batch.updateData(["followingCount": FieldValue.increment(Int64(-1))], forDocument: userDoc(uid))
        batch.updateData(["followersCount": FieldValue.increment(Int64(-1))], forDocument: userDoc(userId))
        
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
    
    /// Friends-of-friends suggestions. Fan-out is bounded on both axes (number of friends we
    /// branch from, and documents read per friend) so the cost stays predictable as the graph grows.
    func fetchRecommendedFriends(
        currentUserId: String,
        maxFriendsToExpand: Int = 20,
        perFriendLimit: Int = 20,
        maxSuggestions: Int = 30,
        completion: @escaping ([String]) -> Void
    ) {
        fetchFollowing(currentUserId: currentUserId) { activeFriendIds in
            let seeds = Array(activeFriendIds.prefix(maxFriendsToExpand))
            let existing = Set(activeFriendIds)
            var suggestedUserIds = Set<String>()
            let dispatchGroup = DispatchGroup()

            for activeFriendId in seeds {
                dispatchGroup.enter()
                self.followingCollection(for: activeFriendId)
                    .limit(to: perFriendLimit)
                    .getDocuments { snapshot, _ in
                        for doc in snapshot?.documents ?? [] {
                            let suggestedId = doc.documentID
                            if !existing.contains(suggestedId) && suggestedId != currentUserId {
                                suggestedUserIds.insert(suggestedId)
                            }
                        }
                        dispatchGroup.leave()
                    }
            }

            dispatchGroup.notify(queue: .main) {
                completion(Array(suggestedUserIds.prefix(maxSuggestions)))
            }
        }
    }
    
    func checkUserIsFollowing(_ user: User, completion: @escaping (Bool) -> Void) {
        guard let uid = auth.currentUser?.uid, let userId = user.id else { return }
        
        followingCollection(for: uid)
            .document(userId)
            .getDocument { snapshot, _ in
                completion(snapshot?.exists ?? false)
            }
    }
}
