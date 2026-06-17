//
//  UserService.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import FirebaseFirestore

struct UserService {
    
    private let db = Firestore.firestore()
    
    // MARK: - Firestore References
    
    private func usersCollection() -> CollectionReference {
        return db.collection("users")
    }
    
    private func userDocument(_ uid: String) -> DocumentReference {
        return usersCollection().document(uid)
    }
    
    // MARK: - Fetch Single User
    
    func fetchUser(withUid uid: String, completion: @escaping (User?) -> Void) {
        userDocument(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user with uid \(uid): \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("No user document found for uid \(uid)")
                completion(nil)
                return
            }
            
            do {
                let user = try snapshot.data(as: User.self)
                completion(user)
            } catch {
                print("Error decoding user for uid \(uid): \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    // MARK: - Fetch Users with Search and Pagination
    
    func fetchUsers(searchText: String?, limit: Int = 20, lastDocument: DocumentSnapshot?, completion: @escaping ([User], DocumentSnapshot?) -> Void) {
        var query: Query = usersCollection()
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
        
        if let searchText = searchText, !searchText.isEmpty {
            let endText = searchText + "\u{f8ff}"
            query = query.whereField("username", isGreaterThanOrEqualTo: searchText)
                         .whereField("username", isLessThanOrEqualTo: endText)
        }
        
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users with search '\(searchText ?? "")': \(error.localizedDescription)")
                completion([], nil)
                return
            }
            
            guard let snapshot = snapshot else {
                print("No snapshot found when fetching users")
                completion([], nil)
                return
            }
            
            let users = snapshot.documents.compactMap { try? $0.data(as: User.self) }
            completion(users, snapshot.documents.last)
        }
    }
}
