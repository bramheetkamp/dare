//
//  User.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import FirebaseAuth
import FirebaseFirestore

struct User: Identifiable, Decodable, Equatable, Hashable {
    @DocumentID var id: String?
    let username: String
    let fullname: String
    let profileImageUrl: String?
    let email: String
    let timestamp: Timestamp
    var followersCount: Int?
    var followingCount: Int?
}

extension User {
    var avatarUrl: String {
        profileImageUrl ?? "https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50"
    }
    
    var isCurrentUser: Bool {
        Auth.auth().currentUser?.uid == id
    }
}
