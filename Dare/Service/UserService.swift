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
    
    // MARK: - Search Users (case-insensitive, username + full name)

    /// Searches across `username` and `fullnameLower` with a case-insensitive prefix match,
    /// merging both result sets (username matches ranked first) and de-duplicating by id.
    ///
    /// This is intentionally *not* cursor-paginated: merging two ordered queries can't share a
    /// single cursor. Callers load more by growing `limit` (see `SearchUsersViewModel`), which is
    /// fine for the bounded sizes of a friend search.
    ///
    /// Firestore needs single-field indexes on `username` and `fullnameLower` (created on demand).
    func searchUsers(matching term: String, limit: Int = 20, completion: @escaping ([User]) -> Void) {
        let q = term.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { completion([]); return }
        let end = q + "\u{f8ff}"

        let group = DispatchGroup()
        var byUsername: [User] = []
        var byName: [User] = []

        group.enter()
        usersCollection()
            .whereField("username", isGreaterThanOrEqualTo: q)
            .whereField("username", isLessThanOrEqualTo: end)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                if let error = error { print("searchUsers(username) failed: \(error.localizedDescription)") }
                byUsername = snapshot?.documents.compactMap { try? $0.data(as: User.self) } ?? []
                group.leave()
            }

        group.enter()
        usersCollection()
            .whereField("fullnameLower", isGreaterThanOrEqualTo: q)
            .whereField("fullnameLower", isLessThanOrEqualTo: end)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                if let error = error { print("searchUsers(fullname) failed: \(error.localizedDescription)") }
                byName = snapshot?.documents.compactMap { try? $0.data(as: User.self) } ?? []
                group.leave()
            }

        group.notify(queue: .main) {
            var seen = Set<String>()
            var merged: [User] = []
            for user in byUsername + byName {
                guard let id = user.id, !seen.contains(id) else { continue }
                seen.insert(id)
                merged.append(user)
            }
            completion(Array(merged.prefix(limit)))
        }
    }

    // MARK: - Batch Fetch by Id

    /// Fetches multiple users by document id, preserving the input order. Used for suggested
    /// people, recent searches, and contact matches. Chunks into Firestore's 10-item `in` limit.
    func fetchUsers(byIds ids: [String], completion: @escaping ([User]) -> Void) {
        let uniqueIds = ids.filter { !$0.isEmpty }.reduced()
        guard !uniqueIds.isEmpty else { completion([]); return }

        let group = DispatchGroup()
        var byId: [String: User] = [:]

        for chunk in uniqueIds.chunked(into: 10) {
            group.enter()
            usersCollection()
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { snapshot, _ in
                    for doc in snapshot?.documents ?? [] {
                        if let user = try? doc.data(as: User.self), let id = user.id { byId[id] = user }
                    }
                    group.leave()
                }
        }

        group.notify(queue: .main) {
            completion(uniqueIds.compactMap { byId[$0] })
        }
    }

    // MARK: - Contact Matching

    /// Returns Dare users whose `phoneHash` matches one of the supplied hashes. The raw phone
    /// number never leaves the device — only its hash (see `PhoneNumberHasher`) is queried.
    func findUsers(byPhoneHashes hashes: [String], completion: @escaping ([User]) -> Void) {
        let uniqueHashes = hashes.reduced()
        guard !uniqueHashes.isEmpty else { completion([]); return }

        let group = DispatchGroup()
        var byId: [String: User] = [:]

        for chunk in uniqueHashes.chunked(into: 10) {
            group.enter()
            usersCollection()
                .whereField("phoneHash", in: chunk)
                .getDocuments { snapshot, _ in
                    for doc in snapshot?.documents ?? [] {
                        if let user = try? doc.data(as: User.self), let id = user.id { byId[id] = user }
                    }
                    group.leave()
                }
        }

        group.notify(queue: .main) {
            completion(Array(byId.values))
        }
    }
}

// MARK: - Collection helpers

private extension Array where Element == String {
    /// Order-preserving de-duplication.
    func reduced() -> [String] {
        var seen = Set<String>()
        return filter { seen.insert($0).inserted }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map { Array(self[$0 ..< Swift.min($0 + size, count)]) }
    }
}
