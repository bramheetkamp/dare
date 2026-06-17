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
