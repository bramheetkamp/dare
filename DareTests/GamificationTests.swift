//
//  GamificationTests.swift
//  DareTests
//
//  Pure tests for streak + level math (no Firebase).
//

import Testing
import Foundation
@testable import Dare

struct StreakCalculatorTests {

    private let cal = Calendar(identifier: .gregorian)

    private func day(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var comps = DateComponents()
        comps.year = y; comps.month = m; comps.day = d; comps.hour = 12
        return Calendar(identifier: .gregorian).date(from: comps)!
    }

    @Test func firstEverActivityStartsAtOne() {
        let streak = StreakCalculator.updatedStreak(previousStreak: 0, lastActive: nil, now: day(2026, 6, 17), calendar: cal)
        #expect(streak == 1)
    }

    @Test func consecutiveDayIncrements() {
        let streak = StreakCalculator.updatedStreak(previousStreak: 4, lastActive: day(2026, 6, 16), now: day(2026, 6, 17), calendar: cal)
        #expect(streak == 5)
    }

    @Test func sameDayDoesNotChange() {
        let streak = StreakCalculator.updatedStreak(previousStreak: 4, lastActive: day(2026, 6, 17), now: day(2026, 6, 17), calendar: cal)
        #expect(streak == 4)
    }

    @Test func missedDayResetsToOne() {
        let streak = StreakCalculator.updatedStreak(previousStreak: 10, lastActive: day(2026, 6, 14), now: day(2026, 6, 17), calendar: cal)
        #expect(streak == 1)
    }

    @Test func isNewDayTrueForNextDay() {
        #expect(StreakCalculator.isNewDay(lastActive: day(2026, 6, 16), now: day(2026, 6, 17), calendar: cal))
    }

    @Test func isNewDayFalseSameDay() {
        #expect(!StreakCalculator.isNewDay(lastActive: day(2026, 6, 17), now: day(2026, 6, 17), calendar: cal))
    }
}

struct StreakFreezeTests {

    private let cal = Calendar(identifier: .gregorian)

    private func day(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var comps = DateComponents()
        comps.year = y; comps.month = m; comps.day = d; comps.hour = 12
        return Calendar(identifier: .gregorian).date(from: comps)!
    }

    // MARK: updatedStreakApplyingFreeze

    @Test func noHistoryStartsAtOne() {
        let r = StreakCalculator.updatedStreakApplyingFreeze(
            previousStreak: 0, lastActive: nil,
            now: day(2026, 6, 17), calendar: cal, freezesAvailable: 3
        )
        #expect(r.newStreak == 1)
        #expect(r.freezeConsumed == false)
    }

    @Test func consecutiveDayIncrementsWithoutFreeze() {
        let r = StreakCalculator.updatedStreakApplyingFreeze(
            previousStreak: 4, lastActive: day(2026, 6, 16),
            now: day(2026, 6, 17), calendar: cal, freezesAvailable: 2
        )
        #expect(r.newStreak == 5)
        #expect(r.freezeConsumed == false)
    }

    @Test func sameDayNoChangeNoFreeze() {
        let r = StreakCalculator.updatedStreakApplyingFreeze(
            previousStreak: 4, lastActive: day(2026, 6, 17),
            now: day(2026, 6, 17), calendar: cal, freezesAvailable: 0
        )
        #expect(r.newStreak == 4)
        #expect(r.freezeConsumed == false)
    }

    @Test func gapResetsWhenNoFreeze() {
        let r = StreakCalculator.updatedStreakApplyingFreeze(
            previousStreak: 10, lastActive: day(2026, 6, 14),
            now: day(2026, 6, 17), calendar: cal, freezesAvailable: 0
        )
        #expect(r.newStreak == 1)
        #expect(r.freezeConsumed == false)
    }

    @Test func freezeSavesStreakOnGap() {
        let r = StreakCalculator.updatedStreakApplyingFreeze(
            previousStreak: 10, lastActive: day(2026, 6, 14),
            now: day(2026, 6, 17), calendar: cal, freezesAvailable: 1
        )
        #expect(r.newStreak == 10)
        #expect(r.freezeConsumed == true)
    }

    @Test func freezeSavesStreakPreservesMinimumOne() {
        let r = StreakCalculator.updatedStreakApplyingFreeze(
            previousStreak: 0, lastActive: day(2026, 6, 14),
            now: day(2026, 6, 17), calendar: cal, freezesAvailable: 1
        )
        #expect(r.newStreak == 1)
        #expect(r.freezeConsumed == true)
    }

    @Test func multipleFreezeAvailableConsumesOnlyOne() {
        let r = StreakCalculator.updatedStreakApplyingFreeze(
            previousStreak: 7, lastActive: day(2026, 6, 10),
            now: day(2026, 6, 17), calendar: cal, freezesAvailable: 3
        )
        // gap of 7 days — freeze bridges it, streak preserved
        #expect(r.newStreak == 7)
        #expect(r.freezeConsumed == true)
    }

    // MARK: earnsFreeze

    @Test func earnsFreeze_at7() {
        #expect(StreakCalculator.earnsFreeze(newStreak: 7) == true)
    }

    @Test func earnsFreeze_at30() {
        #expect(StreakCalculator.earnsFreeze(newStreak: 30) == true)
    }

    @Test func earnsFreeze_at60() {
        #expect(StreakCalculator.earnsFreeze(newStreak: 60) == true)
    }

    @Test func earnsFreeze_at90() {
        #expect(StreakCalculator.earnsFreeze(newStreak: 90) == true)
    }

    @Test func doesNotEarnFreeze_at1() {
        #expect(StreakCalculator.earnsFreeze(newStreak: 1) == false)
    }

    @Test func doesNotEarnFreeze_at6() {
        #expect(StreakCalculator.earnsFreeze(newStreak: 6) == false)
    }

    @Test func doesNotEarnFreeze_at14() {
        #expect(StreakCalculator.earnsFreeze(newStreak: 14) == false)
    }

    @Test func doesNotEarnFreeze_at29() {
        #expect(StreakCalculator.earnsFreeze(newStreak: 29) == false)
    }

    @Test func doesNotEarnFreeze_atZero() {
        #expect(StreakCalculator.earnsFreeze(newStreak: 0) == false)
    }

    @Test func doesNotEarnFreeze_atNegative() {
        #expect(StreakCalculator.earnsFreeze(newStreak: -1) == false)
    }

    // MARK: StreakUpdateResult conformance

    @Test func updateResultEquality() {
        let a = StreakUpdateResult(newStreak: 5, freezeConsumed: false)
        let b = StreakUpdateResult(newStreak: 5, freezeConsumed: false)
        #expect(a == b)
    }
}

struct GamificationLevelTests {

    @Test func levelThresholds() {
        #expect(GamificationLevel.level(for: 0) == 1)
        #expect(GamificationLevel.level(for: 99) == 1)
        #expect(GamificationLevel.level(for: 100) == 2)
        #expect(GamificationLevel.level(for: 299) == 2)
        #expect(GamificationLevel.level(for: 300) == 3)
        #expect(GamificationLevel.level(for: 600) == 4)
    }

    @Test func negativePointsClampToLevelOne() {
        #expect(GamificationLevel.level(for: -50) == 1)
    }

    @Test func progressWithinLevel() {
        let p = GamificationLevel.progress(for: 150) // level 2 starts at 100, span 200
        #expect(p.level == 2)
        #expect(p.into == 50)
        #expect(p.span == 200)
    }

    @Test func fractionIsBetweenZeroAndOne() {
        let f = GamificationLevel.fractionIntoLevel(for: 150)
        #expect(f >= 0 && f <= 1)
        #expect(abs(f - 0.25) < 0.0001) // 50 / 200
    }
}
