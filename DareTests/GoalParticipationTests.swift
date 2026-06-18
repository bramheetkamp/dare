//
//  GoalParticipationTests.swift
//  DareTests
//
//  Pure tests for GoalParticipation helpers — no Firebase, no UI.
//

import Testing
@testable import Dare

struct GoalParticipationTests {

    // MARK: - isJoined

    @Test func isJoined_nilParticipants_returnsFalse() {
        #expect(!GoalParticipation.isJoined(participants: nil, uid: "alice"))
    }

    @Test func isJoined_emptyList_returnsFalse() {
        #expect(!GoalParticipation.isJoined(participants: [], uid: "alice"))
    }

    @Test func isJoined_uidPresent_returnsTrue() {
        #expect(GoalParticipation.isJoined(participants: ["alice", "bob"], uid: "alice"))
    }

    @Test func isJoined_uidAbsent_returnsFalse() {
        #expect(!GoalParticipation.isJoined(participants: ["bob", "carol"], uid: "alice"))
    }

    @Test func isJoined_singleMatch() {
        #expect(GoalParticipation.isJoined(participants: ["alice"], uid: "alice"))
    }

    @Test func isJoined_caseSensitive() {
        // Firebase UIDs are exact-match — "Alice" ≠ "alice".
        #expect(!GoalParticipation.isJoined(participants: ["Alice"], uid: "alice"))
    }

    @Test func isJoined_creatorUidNotAutoIncluded() {
        // The creator's UID is stored in `Challenge.uid`, not in `participants`.
        // Verifies the separation: joining is explicit, not implicit for creators.
        let creatorUid = "creator-123"
        #expect(!GoalParticipation.isJoined(participants: nil, uid: creatorUid))
        #expect(!GoalParticipation.isJoined(participants: [], uid: creatorUid))
    }

    // MARK: - participantCount

    @Test func participantCount_nilParticipants_isZero() {
        #expect(GoalParticipation.participantCount(participants: nil) == 0)
    }

    @Test func participantCount_emptyList_isZero() {
        #expect(GoalParticipation.participantCount(participants: []) == 0)
    }

    @Test func participantCount_oneParticipant() {
        #expect(GoalParticipation.participantCount(participants: ["alice"]) == 1)
    }

    @Test func participantCount_threeParticipants() {
        #expect(GoalParticipation.participantCount(participants: ["a", "b", "c"]) == 3)
    }

    @Test func participantCount_largeList() {
        let many = (1...50).map { "user\($0)" }
        #expect(GoalParticipation.participantCount(participants: many) == 50)
    }
}
