//
//  ChallengeService.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AVFoundation

struct ChallengeService {
    
    func postChallenge(challenge: String, caption: String, emojis: [String], completion: @escaping (Challenge?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let documentRef = Firestore.firestore().collection("challenges").document()
        let data: [String: Any] = [
            "uid": uid,
            "caption": caption.trimmingCharacters(in: .whitespaces),
            "timestamp": Timestamp(date: Date()),
            "challenge": challenge.trimmingCharacters(in: .whitespaces),
            "emojis": emojis
        ]
        
        documentRef.setData(data) { error in
            if let error = error {
                print("DEBUG: Failed to save post to Firestore with error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            documentRef.getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching created challenge: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let snapshot = snapshot else {
                    completion(nil)
                    return
                }
                
                let challenge = try? snapshot.data(as: Challenge.self)
                completion(challenge)
            }
        }
    }
    
    // Fetch challenges for a specific user
    func fetchChallenges(uid: String?, limit: Int, lastDocument: DocumentSnapshot?, completion: @escaping ([Challenge], DocumentSnapshot?) -> Void) {
        var query = Firestore.firestore().collection("challenges")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
        
        if let uid = uid {
            query = query.whereField("uid", isEqualTo: uid)
        }

        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching challenges: \(error.localizedDescription)")
                completion([], nil)
                return
            }

            guard let snapshot = snapshot else {
                print("No snapshot found")
                completion([], nil)
                return
            }

            let challenges = snapshot.documents.compactMap { try? $0.data(as: Challenge.self) }
            completion(challenges, snapshot.documents.last)
        }
    }
    
    // Fetch challenges for a specific category
    func fetchChallenges(categoryId: String?, limit: Int, lastDocument: DocumentSnapshot?, completion: @escaping ([Challenge], DocumentSnapshot?) -> Void) {
        var query = Firestore.firestore().collection("challenges")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
        
        if let categoryId = categoryId {
            query = query.whereField("categoryId", isEqualTo: categoryId)
        }

        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching challenges: \(error.localizedDescription)")
                completion([], nil)
                return
            }

            guard let snapshot = snapshot else {
                print("No snapshot found")
                completion([], nil)
                return
            }

            let challenges = snapshot.documents.compactMap { try? $0.data(as: Challenge.self) }
            completion(challenges, snapshot.documents.last)
        }
    }
    
    // Fetch specific challenge
    func fetchChallenge(challengeId id: String, completion: @escaping (Challenge?) -> Void) {
        let docRef = Firestore.firestore().collection("challenges").document(id)
        
        docRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching challenge: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("Challenge not found")
                completion(nil)
                return
            }
            
            do {
                let challenge = try snapshot.data(as: Challenge.self)
                completion(challenge)
            } catch {
                print("Error decoding Challenge: \(error)")
                completion(nil)
            }
        }
    }
    
    // Fetch challenge category
    func fetchChallengeCategory(challengeCategoryId id: String, completion: @escaping (ChallengeCategory?) -> Void) {
        let docRef = Firestore.firestore().collection("challengeCategories").document(id)
        
        docRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching challenge: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("Challenge not found")
                completion(nil)
                return
            }
            
            do {
                let challengeCategory = try snapshot.data(as: ChallengeCategory.self)
                completion(challengeCategory)
            } catch {
                print("Error decoding Challenge: \(error)")
                completion(nil)
            }
        }
    }
    
    // MARK: - Goal participation

    /// Adds `uid` to the goal's participants array (idempotent via arrayUnion).
    func joinGoal(uid: String, challengeId: String, completion: ((Error?) -> Void)? = nil) {
        Firestore.firestore().collection("challenges").document(challengeId)
            .updateData(["participants": FieldValue.arrayUnion([uid])]) { error in
                if let error { print("joinGoal failed: \(error.localizedDescription)") }
                completion?(error)
            }
    }

    /// Removes `uid` from the goal's participants array.
    func leaveGoal(uid: String, challengeId: String, completion: ((Error?) -> Void)? = nil) {
        Firestore.firestore().collection("challenges").document(challengeId)
            .updateData(["participants": FieldValue.arrayRemove([uid])]) { error in
                if let error { print("leaveGoal failed: \(error.localizedDescription)") }
                completion?(error)
            }
    }

    func fetchChallengeCategories(limit: Int = 50, completion: @escaping ([ChallengeCategory]) -> Void) {
        let query = Firestore.firestore().collection("challengeCategories")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)

        query.getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: Error fetching categories, \(error.localizedDescription)")
                completion([])
                return
            }

            guard let snapshot = snapshot else {
                print("DEBUG: No snapshot found for categories")
                completion([])
                return
            }

            let categories = snapshot.documents.compactMap { try? $0.data(as: ChallengeCategory.self) }
            completion(categories)
        }
    }
    
}
