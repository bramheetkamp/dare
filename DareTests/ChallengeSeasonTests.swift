//
//  ChallengeSeasonTests.swift
//  DareTests
//
//  Pure tests for ChallengeSeasonLogic — no Firebase, no UI.
//

import Testing
import Foundation
@testable import Dare

struct ChallengeSeasonTests {

    private let cal = Calendar(identifier: .gregorian)

    private func date(_ y: Int, _ m: Int, _ d: Int, hour: Int = 12) -> Date {
        var c = DateComponents()
        c.year = y; c.month = m; c.day = d; c.hour = hour
        return Calendar(identifier: .gregorian).date(from: c)!
    }

    // MARK: - isActive

    @Test func isActive_nilNil_alwaysActive() {
        // Legacy goals with no window are always active.
        #expect(ChallengeSeasonLogic.isActive(start: nil, end: nil, at: date(2026, 1, 1)))
        #expect(ChallengeSeasonLogic.isActive(start: nil, end: nil, at: date(2099, 12, 31)))
    }

    @Test func isActive_startOnly_activeAfterStart() {
        let start = date(2026, 6, 1)
        #expect(!ChallengeSeasonLogic.isActive(start: start, end: nil, at: date(2026, 5, 31)))
        #expect(ChallengeSeasonLogic.isActive(start: start, end: nil, at: date(2026, 6, 1)))
        #expect(ChallengeSeasonLogic.isActive(start: start, end: nil, at: date(2026, 12, 31)))
    }

    @Test func isActive_endOnly_activeBeforeEnd() {
        let end = date(2026, 6, 30)
        #expect(ChallengeSeasonLogic.isActive(start: nil, end: end, at: date(2026, 1, 1)))
        #expect(ChallengeSeasonLogic.isActive(start: nil, end: end, at: date(2026, 6, 30)))
        #expect(!ChallengeSeasonLogic.isActive(start: nil, end: end, at: date(2026, 7, 1)))
    }

    @Test func isActive_bothSet_activeWithinWindow() {
        let start = date(2026, 6, 1)
        let end = date(2026, 6, 30)
        #expect(!ChallengeSeasonLogic.isActive(start: start, end: end, at: date(2026, 5, 31)))
        #expect(ChallengeSeasonLogic.isActive(start: start, end: end, at: date(2026, 6, 1)))
        #expect(ChallengeSeasonLogic.isActive(start: start, end: end, at: date(2026, 6, 15)))
        #expect(ChallengeSeasonLogic.isActive(start: start, end: end, at: date(2026, 6, 30)))
        #expect(!ChallengeSeasonLogic.isActive(start: start, end: end, at: date(2026, 7, 1)))
    }

    @Test func isActive_startEqualsEnd_activeOnThatInstant() {
        let d = date(2026, 6, 17)
        #expect(ChallengeSeasonLogic.isActive(start: d, end: d, at: d))
    }

    @Test func isActive_endBeforeStart_neverActive() {
        // Misconfigured season — end before start → window is empty.
        let start = date(2026, 6, 30)
        let end = date(2026, 6, 1)
        #expect(!ChallengeSeasonLogic.isActive(start: start, end: end, at: date(2026, 6, 15)))
    }

    // MARK: - daysRemaining

    @Test func daysRemaining_nilEnd_returnsNil() {
        #expect(ChallengeSeasonLogic.daysRemaining(end: nil, from: date(2026, 6, 17), calendar: cal) == nil)
    }

    @Test func daysRemaining_futureEnd() {
        let end = date(2026, 6, 20)
        let result = ChallengeSeasonLogic.daysRemaining(end: end, from: date(2026, 6, 17), calendar: cal)
        #expect(result == 3)
    }

    @Test func daysRemaining_sameDay_returnsZero() {
        let d = date(2026, 6, 17)
        let result = ChallengeSeasonLogic.daysRemaining(end: d, from: d, calendar: cal)
        #expect(result == 0)
    }

    @Test func daysRemaining_pastEnd_clampsToZero() {
        let end = date(2026, 6, 1)
        let result = ChallengeSeasonLogic.daysRemaining(end: end, from: date(2026, 6, 17), calendar: cal)
        #expect(result == 0)
    }

    @Test func daysRemaining_endLateInDayStillCounts() {
        // End is 23:59 on the same calendar day — daysRemaining compares startOfDay.
        var endComps = DateComponents()
        endComps.year = 2026; endComps.month = 6; endComps.day = 17
        endComps.hour = 23; endComps.minute = 59
        let end = cal.date(from: endComps)!
        let result = ChallengeSeasonLogic.daysRemaining(end: end, from: date(2026, 6, 17, hour: 0), calendar: cal)
        #expect(result == 0)   // same calendar day
    }

    @Test func daysRemaining_oneMonthAhead() {
        // June has 30 days; June 17 → July 17 = 30 days.
        let result = ChallengeSeasonLogic.daysRemaining(
            end: date(2026, 7, 17),
            from: date(2026, 6, 17),
            calendar: cal
        )
        #expect(result == 30)
    }

    // MARK: - progressFraction

    @Test func progressFraction_nilStart_returnsNil() {
        #expect(ChallengeSeasonLogic.progressFraction(start: nil, end: date(2026, 6, 30)) == nil)
    }

    @Test func progressFraction_nilEnd_returnsNil() {
        #expect(ChallengeSeasonLogic.progressFraction(start: date(2026, 6, 1), end: nil) == nil)
    }

    @Test func progressFraction_bothNil_returnsNil() {
        #expect(ChallengeSeasonLogic.progressFraction(start: nil, end: nil) == nil)
    }

    @Test func progressFraction_halfwayThrough() {
        let start = date(2026, 6, 1)
        let end = date(2026, 6, 30)
        // Halfway = June 15 (using 29-day span; exact value depends on hours, so ≈ 0.5)
        let halfway = date(2026, 6, 15, hour: 12) // ≈ day 14.5 / 29
        let fraction = ChallengeSeasonLogic.progressFraction(start: start, end: end, at: halfway)!
        #expect(fraction > 0.4 && fraction < 0.6)
    }

    @Test func progressFraction_beforeStart_clampsToZero() {
        let start = date(2026, 6, 10)
        let end = date(2026, 6, 30)
        let fraction = ChallengeSeasonLogic.progressFraction(start: start, end: end, at: date(2026, 6, 1))!
        #expect(fraction == 0.0)
    }

    @Test func progressFraction_afterEnd_clampsToOne() {
        let start = date(2026, 6, 1)
        let end = date(2026, 6, 30)
        let fraction = ChallengeSeasonLogic.progressFraction(start: start, end: end, at: date(2026, 7, 15))!
        #expect(fraction == 1.0)
    }

    @Test func progressFraction_atExactStart_isZero() {
        let start = date(2026, 6, 1)
        let end = date(2026, 6, 30)
        let fraction = ChallengeSeasonLogic.progressFraction(start: start, end: end, at: start)!
        #expect(fraction == 0.0)
    }

    @Test func progressFraction_atExactEnd_isOne() {
        let start = date(2026, 6, 1)
        let end = date(2026, 6, 30)
        let fraction = ChallengeSeasonLogic.progressFraction(start: start, end: end, at: end)!
        #expect(fraction == 1.0)
    }

    @Test func progressFraction_zeroDurationSeason_isOne() {
        // start == end means the season is instantaneous; treated as complete.
        let d = date(2026, 6, 17)
        let fraction = ChallengeSeasonLogic.progressFraction(start: d, end: d, at: d)!
        #expect(fraction == 1.0)
    }

    // MARK: - statusLabel

    @Test func statusLabel_nilEnd_returnsNil() {
        #expect(ChallengeSeasonLogic.statusLabel(end: nil) == nil)
    }

    @Test func statusLabel_lastDay() {
        let result = ChallengeSeasonLogic.statusLabel(
            end: date(2026, 6, 17),
            from: date(2026, 6, 17),
            calendar: cal
        )
        #expect(result == "Last day!")
    }

    @Test func statusLabel_oneDay() {
        let result = ChallengeSeasonLogic.statusLabel(
            end: date(2026, 6, 18),
            from: date(2026, 6, 17),
            calendar: cal
        )
        #expect(result == "1 day left")
    }

    @Test func statusLabel_multipleDays() {
        let result = ChallengeSeasonLogic.statusLabel(
            end: date(2026, 6, 27),
            from: date(2026, 6, 17),
            calendar: cal
        )
        #expect(result == "10 days left")
    }

    @Test func statusLabel_pastEnd_lastDay() {
        // Already ended — daysRemaining clamps to 0.
        let result = ChallengeSeasonLogic.statusLabel(
            end: date(2026, 6, 1),
            from: date(2026, 6, 17),
            calendar: cal
        )
        #expect(result == "Last day!")
    }
}
