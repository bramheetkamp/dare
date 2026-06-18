//
//  YearAgoNotificationLogicTests.swift
//  DareTests
//
//  Pure unit tests for YearAgoNotificationLogic — no Firebase, no UI, no network.
//

import Testing
import Foundation
@testable import Dare

struct YearAgoNotificationLogicTests {

    private let cal = Calendar(identifier: .gregorian)

    // Reference "today" = 2026-06-18 noon.
    private let reference = date(2026, 6, 18)
    // One year ago = 2025-06-18; window = ±14 days = [2025-06-04, 2025-07-02]

    private static func date(_ y: Int, _ m: Int, _ d: Int, hour: Int = 12) -> Date {
        var c = DateComponents()
        c.year = y; c.month = m; c.day = d; c.hour = hour
        return Calendar(identifier: .gregorian).date(from: c)!
    }

    private func post(_ id: String, _ y: Int, _ m: Int, _ d: Int) -> (id: String, date: Date) {
        (id: id, date: Self.date(y, m, d))
    }

    // MARK: - bestPostId

    @Test func bestPostId_emptyArray_returnsNil() {
        #expect(
            YearAgoNotificationLogic.bestPostId(
                from: [],
                reference: reference,
                calendar: cal
            ) == nil
        )
    }

    @Test func bestPostId_postInWindow_returnsIt() {
        let posts = [post("p1", 2025, 6, 18)]   // exactly one year ago
        #expect(
            YearAgoNotificationLogic.bestPostId(
                from: posts,
                reference: reference,
                calendar: cal
            ) == "p1"
        )
    }

    @Test func bestPostId_postOutsideWindow_returnsNil() {
        // 2025-05-01 is 48 days before one-year-ago (2025-06-18) → outside ±14 window.
        let posts = [post("p1", 2025, 5, 1)]
        #expect(
            YearAgoNotificationLogic.bestPostId(
                from: posts,
                reference: reference,
                calendar: cal
            ) == nil
        )
    }

    @Test func bestPostId_twoPostsInWindow_returnsClosest() {
        // p2 is closer to 2025-06-18 than p1 (2025-06-10 vs 2025-06-20)
        let posts = [post("p1", 2025, 6, 10), post("p2", 2025, 6, 20)]
        // |2025-06-10 − 2025-06-18| = 8 days vs |2025-06-20 − 2025-06-18| = 2 days → p2 wins
        #expect(
            YearAgoNotificationLogic.bestPostId(
                from: posts,
                reference: reference,
                calendar: cal
            ) == "p2"
        )
    }

    @Test func bestPostId_postAtLowerBoundary_included() {
        // Exactly at start of window: 2025-06-04 (−14 days from 2025-06-18)
        let posts = [post("pEdge", 2025, 6, 4)]
        #expect(
            YearAgoNotificationLogic.bestPostId(
                from: posts,
                reference: reference,
                calendar: cal
            ) == "pEdge"
        )
    }

    @Test func bestPostId_postAtUpperBoundary_included() {
        // Exactly at end of window: 2025-07-02 (+14 days from 2025-06-18)
        let posts = [post("pEdge", 2025, 7, 2)]
        #expect(
            YearAgoNotificationLogic.bestPostId(
                from: posts,
                reference: reference,
                calendar: cal
            ) == "pEdge"
        )
    }

    @Test func bestPostId_onePostInsideOneOutside_returnsInside() {
        let posts = [
            post("outside", 2025, 4, 1),   // well outside window
            post("inside",  2025, 6, 15)   // inside window
        ]
        #expect(
            YearAgoNotificationLogic.bestPostId(
                from: posts,
                reference: reference,
                calendar: cal
            ) == "inside"
        )
    }

    // MARK: - notificationBody

    @Test func notificationBody_withNote_quotesNote() {
        let body = YearAgoNotificationLogic.notificationBody(note: "first clean pull-up")
        #expect(body.contains("first clean pull-up"))
        #expect(body.contains("A year ago you posted"))
    }

    @Test func notificationBody_nilNote_returnsFallback() {
        let body = YearAgoNotificationLogic.notificationBody(note: nil)
        #expect(body.contains("working on a year ago"))
    }

    @Test func notificationBody_emptyNote_returnsFallback() {
        let body = YearAgoNotificationLogic.notificationBody(note: "")
        #expect(body.contains("working on a year ago"))
    }

    @Test func notificationBody_whitespaceNote_returnsFallback() {
        // Whitespace-only note should be treated as empty by the caller; the function
        // itself treats any non-empty string as valid — this test documents that contract.
        let body = YearAgoNotificationLogic.notificationBody(note: "   ")
        #expect(body.contains("A year ago you posted"))
    }
}
