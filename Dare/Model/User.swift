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
    let location: String?
    let description: String?
    var isFollowing: Bool?
    var followersCount: Int?
    var followingCount: Int?

    // MARK: Search / discovery (optional — older documents decode these as nil)
    /// Lowercased full name, written on register/update so name search is case-insensitive.
    var fullnameLower: String?
    /// SHA-256 of the user's phone number in E.164 form. Lets contacts be matched without ever
    /// storing or transmitting a raw phone number. See `PhoneNumberHasher`.
    var phoneHash: String?

    // MARK: Gamification (optional — older documents decode these as nil)
    var points: Int?
    var currentStreak: Int?
    var longestStreak: Int?
    var lastActiveAt: Timestamp?
    /// Earned freeze tokens. A freeze protects the streak when the user misses one period.
    var streakFreezeCount: Int?
}

extension User {
    var avatarUrl: String {
        profileImageUrl ?? "https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50"
    }

    var isCurrentUser: Bool {
        Auth.auth().currentUser?.uid == id
    }

    // MARK: Gamification helpers
    var totalPoints: Int { points ?? 0 }
    var streak: Int { currentStreak ?? 0 }
    var bestStreak: Int { longestStreak ?? 0 }
    var level: Int { GamificationLevel.level(for: totalPoints) }
    var freezeCount: Int { streakFreezeCount ?? 0 }
}
