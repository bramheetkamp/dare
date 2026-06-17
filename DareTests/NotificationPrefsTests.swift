//
//  NotificationPrefsTests.swift
//  DareTests
//
//  Pure tests for NotificationPrefs — no Firebase, no UserNotifications.
//

import Testing
import Foundation
@testable import Dare

struct NotificationPrefsTests {

    // MARK: - Default initialisation

    @Test func defaultInit_weeklyRitualIsTrue() {
        let prefs = NotificationPrefs()
        #expect(prefs.weeklyRitual == true)
    }

    @Test func customInit_weeklyRitualFalse() {
        let prefs = NotificationPrefs(weeklyRitual: false)
        #expect(prefs.weeklyRitual == false)
    }

    // MARK: - Codable round-trip

    @Test func codable_roundTrip_true() throws {
        let original = NotificationPrefs(weeklyRitual: true)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(NotificationPrefs.self, from: data)
        #expect(decoded == original)
    }

    @Test func codable_roundTrip_false() throws {
        let original = NotificationPrefs(weeklyRitual: false)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(NotificationPrefs.self, from: data)
        #expect(decoded == original)
    }

    // MARK: - Resilient decoding (missing keys → defaults)

    @Test func decode_emptyJSON_returnsDefaults() throws {
        let json = "{}".data(using: .utf8)!
        let prefs = try JSONDecoder().decode(NotificationPrefs.self, from: json)
        #expect(prefs.weeklyRitual == true)
    }

    @Test func decode_partialJSON_honorsPresentField() throws {
        let json = #"{"weeklyRitual": false}"#.data(using: .utf8)!
        let prefs = try JSONDecoder().decode(NotificationPrefs.self, from: json)
        #expect(prefs.weeklyRitual == false)
    }

    @Test func decode_extraUnknownField_decodesCleanly() throws {
        // Future Firestore keys the client doesn't know about must not crash decoding.
        let json = #"{"weeklyRitual": true, "unknownFutureKey": 42}"#.data(using: .utf8)!
        let prefs = try JSONDecoder().decode(NotificationPrefs.self, from: json)
        #expect(prefs.weeklyRitual == true)
    }

    // MARK: - Mutation helper

    @Test func withWeeklyRitual_producesCorrectCopy() {
        let original = NotificationPrefs(weeklyRitual: true)
        let mutated = original.withWeeklyRitual(false)
        #expect(mutated.weeklyRitual == false)
        #expect(original.weeklyRitual == true) // original unchanged
    }

    @Test func withWeeklyRitual_noOpWhenSameValue() {
        let prefs = NotificationPrefs(weeklyRitual: true)
        #expect(prefs.withWeeklyRitual(true) == prefs)
    }

    // MARK: - Equatable

    @Test func equality_sameValues() {
        #expect(NotificationPrefs(weeklyRitual: true) == NotificationPrefs(weeklyRitual: true))
        #expect(NotificationPrefs(weeklyRitual: false) == NotificationPrefs(weeklyRitual: false))
    }

    @Test func equality_differentValues() {
        #expect(NotificationPrefs(weeklyRitual: true) != NotificationPrefs(weeklyRitual: false))
    }

    // MARK: - Firestore key constant

    @Test func firestoreKey_isNonEmpty() {
        #expect(!NotificationPrefs.firestoreKey.isEmpty)
    }
}
