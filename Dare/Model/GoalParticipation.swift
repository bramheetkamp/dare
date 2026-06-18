//
//  GoalParticipation.swift
//  Dare
//
//  Pure helpers for goal participation logic. No Firebase imports — fully unit-testable.
//

import Foundation

enum GoalParticipation {

    /// `true` if `uid` is in the `participants` list. `nil` or empty list → false.
    static func isJoined(participants: [String]?, uid: String) -> Bool {
        participants?.contains(uid) ?? false
    }

    /// Number of explicit participants. Returns 0 when the list is nil.
    static func participantCount(participants: [String]?) -> Int {
        participants?.count ?? 0
    }
}
