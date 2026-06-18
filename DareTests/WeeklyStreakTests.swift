//
//  WeeklyStreakTests.swift
//  DareTests
//
//  Pure tests for the weekly goal-update streak system.
//  All dates are injected; no Firebase, no network.
//

import Testing
import Foundation
@testable import Dare

struct WeeklyStreakTests {

    // ISO week-aware Gregorian calendar (Monday = first weekday)
    private var cal: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2  // Monday
        return c
    }

    // Helper: build a date for year/month/day at noon.
    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var comps = DateComponents()
        comps.year = y; comps.month = m; comps.day = d; comps.hour = 12
        return Calendar(identifier: .gregorian).date(from: comps)!
    }

    // MARK: - weeksBetween

    @Test func weeksBetweenSameDay() {
        let d = date(2026, 6, 10)
        #expect(StreakCalculator.weeksBetween(from: d, to: d, calendar: cal) == 0)
    }

    @Test func weeksBetweenSameWeekDifferentDays() {
        // Jun 8 (Mon) and Jun 12 (Fri) are in the same ISO week.
        let mon = date(2026, 6, 8)
        let fri = date(2026, 6, 12)
        #expect(StreakCalculator.weeksBetween(from: mon, to: fri, calendar: cal) == 0)
    }

    @Test func weeksBetweenConsecutiveWeeks() {
        // Jun 8 (Mon, wk23) → Jun 15 (Mon, wk24)
        let wk23 = date(2026, 6, 8)
        let wk24 = date(2026, 6, 15)
        #expect(StreakCalculator.weeksBetween(from: wk23, to: wk24, calendar: cal) == 1)
    }

    @Test func weeksBetweenTwoWeekGap() {
        let wk23 = date(2026, 6, 8)
        let wk25 = date(2026, 6, 22)
        #expect(StreakCalculator.weeksBetween(from: wk23, to: wk25, calendar: cal) == 2)
    }

    @Test func weeksBetweenNegativeWhenToBeforeFrom() {
        let later = date(2026, 6, 22)
        let earlier = date(2026, 6, 8)
        #expect(StreakCalculator.weeksBetween(from: later, to: earlier, calendar: cal) == -2)
    }

    @Test func weeksBetweenAcrossYearBoundary() {
        // Dec 28, 2026 (Mon, wk52) → Jan 4, 2027 (Mon, wk1 of 2027) — 1 week
        let dec28 = date(2026, 12, 28)
        let jan4  = date(2027, 1, 4)
        #expect(StreakCalculator.weeksBetween(from: dec28, to: jan4, calendar: cal) == 1)
    }

    // MARK: - isNewWeek

    @Test func isNewWeekTrueWhenNoHistory() {
        #expect(StreakCalculator.isNewWeek(lastGoalUpdate: nil, now: date(2026, 6, 15), calendar: cal))
    }

    @Test func isNewWeekFalseInSameWeek() {
        let mon = date(2026, 6, 8)
        let wed = date(2026, 6, 10)
        #expect(!StreakCalculator.isNewWeek(lastGoalUpdate: mon, now: wed, calendar: cal))
    }

    @Test func isNewWeekTrueInNextWeek() {
        let wk23 = date(2026, 6, 10)
        let wk24 = date(2026, 6, 17)
        #expect(StreakCalculator.isNewWeek(lastGoalUpdate: wk23, now: wk24, calendar: cal))
    }

    // MARK: - updatedWeeklyStreak

    @Test func weeklyStreak_firstEverStartsAtOne() {
        let s = StreakCalculator.updatedWeeklyStreak(
            previousStreak: 0, lastGoalUpdate: nil,
            now: date(2026, 6, 15), calendar: cal)
        #expect(s == 1)
    }

    @Test func weeklyStreak_sameWeekIsUnchanged() {
        let s = StreakCalculator.updatedWeeklyStreak(
            previousStreak: 5, lastGoalUpdate: date(2026, 6, 8),
            now: date(2026, 6, 10), calendar: cal)
        #expect(s == 5)
    }

    @Test func weeklyStreak_consecutiveWeekIncrements() {
        let s = StreakCalculator.updatedWeeklyStreak(
            previousStreak: 5, lastGoalUpdate: date(2026, 6, 8),
            now: date(2026, 6, 15), calendar: cal)
        #expect(s == 6)
    }

    @Test func weeklyStreak_twoWeekGapResetsToOne() {
        let s = StreakCalculator.updatedWeeklyStreak(
            previousStreak: 10, lastGoalUpdate: date(2026, 6, 1),
            now: date(2026, 6, 22), calendar: cal)
        #expect(s == 1)
    }

    @Test func weeklyStreak_clockSkewDoesNotPunish() {
        // `now` appears to be in an earlier week than `lastGoalUpdate` (skew).
        let s = StreakCalculator.updatedWeeklyStreak(
            previousStreak: 7, lastGoalUpdate: date(2026, 6, 22),
            now: date(2026, 6, 10), calendar: cal)
        #expect(s >= 1)
    }

    @Test func weeklyStreak_sameWeekMinimumIsOne() {
        let s = StreakCalculator.updatedWeeklyStreak(
            previousStreak: 0, lastGoalUpdate: date(2026, 6, 8),
            now: date(2026, 6, 9), calendar: cal)
        #expect(s == 1)
    }

    // MARK: - updatedWeeklyStreakApplyingFreeze

    @Test func weeklyFreeze_noHistoryStartsAtOne() {
        let r = StreakCalculator.updatedWeeklyStreakApplyingFreeze(
            previousStreak: 0, lastGoalUpdate: nil,
            now: date(2026, 6, 15), calendar: cal, freezesAvailable: 3)
        #expect(r.newStreak == 1)
        #expect(!r.freezeConsumed)
    }

    @Test func weeklyFreeze_sameWeekNoChange() {
        let r = StreakCalculator.updatedWeeklyStreakApplyingFreeze(
            previousStreak: 4, lastGoalUpdate: date(2026, 6, 8),
            now: date(2026, 6, 10), calendar: cal, freezesAvailable: 0)
        #expect(r.newStreak == 4)
        #expect(!r.freezeConsumed)
    }

    @Test func weeklyFreeze_consecutiveWeekIncrements() {
        let r = StreakCalculator.updatedWeeklyStreakApplyingFreeze(
            previousStreak: 4, lastGoalUpdate: date(2026, 6, 8),
            now: date(2026, 6, 15), calendar: cal, freezesAvailable: 2)
        #expect(r.newStreak == 5)
        #expect(!r.freezeConsumed)
    }

    @Test func weeklyFreeze_gapResetsWithNoFreeze() {
        let r = StreakCalculator.updatedWeeklyStreakApplyingFreeze(
            previousStreak: 10, lastGoalUpdate: date(2026, 6, 1),
            now: date(2026, 6, 22), calendar: cal, freezesAvailable: 0)
        #expect(r.newStreak == 1)
        #expect(!r.freezeConsumed)
    }

    @Test func weeklyFreeze_freezeSavesStreakOnGap() {
        let r = StreakCalculator.updatedWeeklyStreakApplyingFreeze(
            previousStreak: 8, lastGoalUpdate: date(2026, 6, 1),
            now: date(2026, 6, 22), calendar: cal, freezesAvailable: 1)
        #expect(r.newStreak == 8)
        #expect(r.freezeConsumed)
    }

    @Test func weeklyFreeze_freezePreservesMinimumOne() {
        let r = StreakCalculator.updatedWeeklyStreakApplyingFreeze(
            previousStreak: 0, lastGoalUpdate: date(2026, 6, 1),
            now: date(2026, 6, 22), calendar: cal, freezesAvailable: 1)
        #expect(r.newStreak == 1)
        #expect(r.freezeConsumed)
    }

    // MARK: - earnsWeeklyFreeze

    @Test func earnsWeeklyFreeze_at4() {
        #expect(StreakCalculator.earnsWeeklyFreeze(newStreak: 4))
    }

    @Test func earnsWeeklyFreeze_at12() {
        #expect(StreakCalculator.earnsWeeklyFreeze(newStreak: 12))
    }

    @Test func earnsWeeklyFreeze_at24() {
        #expect(StreakCalculator.earnsWeeklyFreeze(newStreak: 24))
    }

    @Test func earnsWeeklyFreeze_at36() {
        #expect(StreakCalculator.earnsWeeklyFreeze(newStreak: 36))
    }

    @Test func doesNotEarnWeeklyFreeze_at1() {
        #expect(!StreakCalculator.earnsWeeklyFreeze(newStreak: 1))
    }

    @Test func doesNotEarnWeeklyFreeze_at3() {
        #expect(!StreakCalculator.earnsWeeklyFreeze(newStreak: 3))
    }

    @Test func doesNotEarnWeeklyFreeze_at5() {
        #expect(!StreakCalculator.earnsWeeklyFreeze(newStreak: 5))
    }

    @Test func doesNotEarnWeeklyFreeze_at11() {
        #expect(!StreakCalculator.earnsWeeklyFreeze(newStreak: 11))
    }

    @Test func doesNotEarnWeeklyFreeze_at13() {
        #expect(!StreakCalculator.earnsWeeklyFreeze(newStreak: 13))
    }

    @Test func doesNotEarnWeeklyFreeze_atZero() {
        #expect(!StreakCalculator.earnsWeeklyFreeze(newStreak: 0))
    }

    @Test func doesNotEarnWeeklyFreeze_atNegative() {
        #expect(!StreakCalculator.earnsWeeklyFreeze(newStreak: -1))
    }

    // MARK: - PointEvent

    @Test func weeklyGoalPostPointValue() {
        #expect(PointEvent.weeklyGoalPost.rawValue == 50)
    }

    @Test func weeklyGoalPostHigherThanDailyCheckIn() {
        #expect(PointEvent.weeklyGoalPost.rawValue > PointEvent.dailyCheckIn.rawValue)
    }
}
