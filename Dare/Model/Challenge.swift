//
//  Challenge.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import FirebaseFirestore

struct Challenge: Identifiable, Decodable, Equatable, Hashable {
    @DocumentID var id: String?
    let challenge: String
    let caption: String
    let timestamp: Timestamp
    let uid: String
    let categoryId: String?

    var updates: Int?
    var imageUrl: String?
    var emojis: [String]?

    // Optional season window — if present the challenge is a time-boxed "season".
    // Old documents decode to nil (backward-compatible).
    var startsAt: Timestamp?
    var endsAt: Timestamp?

    // UIDs of users who have explicitly joined this goal (creator is NOT auto-included).
    // Old documents decode to nil (backward-compatible).
    var participants: [String]?

    var user: User?

    // MARK: - Convenience accessors (plain Date, no Firestore dependency for callers)

    /// The effective start of this season, falling back to when the challenge was created.
    var startDate: Date { (startsAt ?? timestamp).dateValue() }
    /// The season end date, or nil if the challenge runs indefinitely.
    var endDate: Date? { endsAt?.dateValue() }

    // MARK: - Participation helpers

    /// `true` if `uid` has explicitly joined this goal.
    func isJoined(by uid: String) -> Bool {
        GoalParticipation.isJoined(participants: participants, uid: uid)
    }

    /// Number of users who have joined this goal (excluding the creator).
    var participantCount: Int {
        GoalParticipation.participantCount(participants: participants)
    }
}
