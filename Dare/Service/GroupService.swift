//
//  GroupService.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import FirebaseFirestore
import FirebaseAuth

/// Firestore access for groups.
///
/// Layout:
///   groups/{groupId}                         — the group document
///   groups/{groupId}/members/{uid}           — membership (source of truth for the roster)
///   users/{uid}/groups/{groupId}             — mirror, so "my groups" is a cheap single-collection read
struct GroupService {

    private let db = Firestore.firestore()
    private let auth = Auth.auth()

    private func groupsCollection() -> CollectionReference { db.collection("groups") }
    private func groupDoc(_ id: String) -> DocumentReference { groupsCollection().document(id) }
    private func membersCollection(_ groupId: String) -> CollectionReference { groupDoc(groupId).collection("members") }
    private func userGroupsCollection(_ uid: String) -> CollectionReference { db.collection("users").document(uid).collection("groups") }

    // MARK: - Create

    func createGroup(name: String, description: String?, emoji: String?, isPublic: Bool, completion: @escaping (DareGroup?) -> Void) {
        guard let uid = auth.currentUser?.uid else { completion(nil); return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { completion(nil); return }

        let ref = groupsCollection().document()
        let data: [String: Any] = [
            "name": trimmedName,
            "nameLower": trimmedName.lowercased(),
            "description": description?.trimmingCharacters(in: .whitespacesAndNewlines) as Any,
            "emoji": (emoji?.isEmpty == false ? emoji : nil) as Any,
            "isPublic": isPublic,
            "memberCount": 1,
            "createdBy": uid,
            "timestamp": Timestamp(date: Date())
        ]

        ref.setData(data) { error in
            if let error = error {
                print("DEBUG: Failed to create group: \(error.localizedDescription)")
                completion(nil)
                return
            }
            // Creator joins automatically.
            self.writeMembership(groupId: ref.documentID, uid: uid, joined: true, adjustCount: false) {
                ref.getDocument { snapshot, _ in
                    var group = try? snapshot?.data(as: DareGroup.self)
                    group?.isMember = true
                    completion(group)
                }
            }
        }
    }

    // MARK: - Membership

    func joinGroup(_ groupId: String, completion: @escaping (Bool) -> Void) {
        guard let uid = auth.currentUser?.uid else { completion(false); return }
        writeMembership(groupId: groupId, uid: uid, joined: true, adjustCount: true) { completion(true) }
    }

    func leaveGroup(_ groupId: String, completion: @escaping (Bool) -> Void) {
        guard let uid = auth.currentUser?.uid else { completion(false); return }
        writeMembership(groupId: groupId, uid: uid, joined: false, adjustCount: true) { completion(true) }
    }

    /// Writes/removes both membership records and (optionally) adjusts the cached member count.
    private func writeMembership(groupId: String, uid: String, joined: Bool, adjustCount: Bool, completion: @escaping () -> Void) {
        let batch = db.batch()
        let memberRef = membersCollection(groupId).document(uid)
        let mirrorRef = userGroupsCollection(uid).document(groupId)

        if joined {
            batch.setData(["joinedAt": Timestamp(date: Date())], forDocument: memberRef)
            batch.setData(["joinedAt": Timestamp(date: Date())], forDocument: mirrorRef)
            if adjustCount { batch.updateData(["memberCount": FieldValue.increment(Int64(1))], forDocument: groupDoc(groupId)) }
        } else {
            batch.deleteDocument(memberRef)
            batch.deleteDocument(mirrorRef)
            if adjustCount { batch.updateData(["memberCount": FieldValue.increment(Int64(-1))], forDocument: groupDoc(groupId)) }
        }

        batch.commit { error in
            if let error = error { print("DEBUG: membership write failed: \(error.localizedDescription)") }
            completion()
        }
    }

    func isMember(of groupId: String, completion: @escaping (Bool) -> Void) {
        guard let uid = auth.currentUser?.uid else { completion(false); return }
        membersCollection(groupId).document(uid).getDocument { snapshot, _ in
            completion(snapshot?.exists ?? false)
        }
    }

    // MARK: - Search & Fetch

    /// Case-insensitive prefix search over public groups by name. Needs a single-field index on
    /// `nameLower` (created on demand).
    func searchGroups(matching term: String, limit: Int = 20, completion: @escaping ([DareGroup]) -> Void) {
        let q = term.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { completion([]); return }
        let end = q + "\u{f8ff}"

        groupsCollection()
            .whereField("nameLower", isGreaterThanOrEqualTo: q)
            .whereField("nameLower", isLessThanOrEqualTo: end)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                if let error = error { print("DEBUG: searchGroups failed: \(error.localizedDescription)") }
                let groups = snapshot?.documents.compactMap { try? $0.data(as: DareGroup.self) } ?? []
                completion(groups)
            }
    }

    func fetchGroup(_ id: String, completion: @escaping (DareGroup?) -> Void) {
        groupDoc(id).getDocument { snapshot, _ in
            completion(try? snapshot?.data(as: DareGroup.self))
        }
    }

    /// The groups the signed-in user belongs to, via the per-user mirror collection.
    func fetchMyGroups(completion: @escaping ([DareGroup]) -> Void) {
        guard let uid = auth.currentUser?.uid else { completion([]); return }
        userGroupsCollection(uid).getDocuments { snapshot, _ in
            let ids = snapshot?.documents.map { $0.documentID } ?? []
            guard !ids.isEmpty else { completion([]); return }

            let group = DispatchGroup()
            var byId: [String: DareGroup] = [:]
            for id in ids {
                group.enter()
                self.fetchGroup(id) { fetched in
                    if var fetched, let fid = fetched.id { fetched.isMember = true; byId[fid] = fetched }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                completion(ids.compactMap { byId[$0] })
            }
        }
    }
}
