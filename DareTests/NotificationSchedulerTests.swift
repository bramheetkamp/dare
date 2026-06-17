//
//  NotificationSchedulerTests.swift
//  DareTests
//
//  Pure tests for NotificationScheduler — no UserNotifications import needed.
//  All tests inject a fixed UTC calendar to avoid timezone flakiness.
//

import Testing
import Foundation
@testable import Dare

struct NotificationSchedulerTests {

    private var utcCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }

    // MARK: - Core invariants

    @Test func nextRitualDate_isStrictlyInFuture() {
        let now = Date()
        let next = NotificationScheduler.nextRitualDate(after: now, calendar: utcCalendar)
        #expect(next > now)
    }

    @Test func nextRitualDate_landsOnCorrectWeekday_Sunday() {
        let now = Date()
        let next = NotificationScheduler.nextRitualDate(after: now, weekday: 1, hour: 10, calendar: utcCalendar)
        let weekday = utcCalendar.component(.weekday, from: next)
        #expect(weekday == 1)
    }

    @Test func nextRitualDate_landsOnCorrectWeekday_allDays() {
        let now = Date()
        for wd in 1...7 {
            let next = NotificationScheduler.nextRitualDate(after: now, weekday: wd, calendar: utcCalendar)
            let weekday = utcCalendar.component(.weekday, from: next)
            #expect(weekday == wd, "Expected weekday \(wd) but got \(weekday)")
        }
    }

    @Test func nextRitualDate_landsAtCorrectHour() {
        let now = Date()
        let next = NotificationScheduler.nextRitualDate(after: now, weekday: 1, hour: 10, calendar: utcCalendar)
        let hour = utcCalendar.component(.hour, from: next)
        #expect(hour == 10)
    }

    @Test func nextRitualDate_landsAtCorrectMinute() {
        let now = Date()
        let next = NotificationScheduler.nextRitualDate(after: now, weekday: 1, hour: 10, minute: 30, calendar: utcCalendar)
        let minute = utcCalendar.component(.minute, from: next)
        #expect(minute == 30)
    }

    @Test func nextRitualDate_isAtMostSevenDaysAway() {
        let now = Date()
        let next = NotificationScheduler.nextRitualDate(after: now, calendar: utcCalendar)
        let gap = next.timeIntervalSince(now)
        #expect(gap <= 7 * 86_400 + 60) // 7 days + 1-minute tolerance
    }

    // MARK: - Edge case: "now" is exactly Sunday 10:00 UTC

    @Test func nextRitualDate_whenNowIsExactFiringTime_returnsNextWeek() {
        // 2026-01-04 is a Sunday
        var comps = DateComponents()
        comps.year = 2026; comps.month = 1; comps.day = 4
        comps.hour = 10; comps.minute = 0; comps.second = 0
        let exactSunday = utcCalendar.date(from: comps)!

        let next = NotificationScheduler.nextRitualDate(
            after: exactSunday, weekday: 1, hour: 10, calendar: utcCalendar
        )
        #expect(next > exactSunday)
        // The next Sunday should be ~7 days later
        let dayGap = utcCalendar.dateComponents([.day], from: exactSunday, to: next).day ?? 0
        #expect(dayGap >= 1)
    }

    // MARK: - Known date → known result

    @Test func nextRitualDate_knownMonday_returnsSameWeekSunday() {
        // 2026-01-05 is a Monday (weekday = 2 in Gregorian).
        // The next Sunday (weekday 1) at 10:00 UTC should be 2026-01-11.
        var comps = DateComponents()
        comps.year = 2026; comps.month = 1; comps.day = 5
        comps.hour = 8; comps.minute = 0; comps.second = 0
        let monday = utcCalendar.date(from: comps)!

        let next = NotificationScheduler.nextRitualDate(
            after: monday, weekday: 1, hour: 10, calendar: utcCalendar
        )

        var expectComps = DateComponents()
        expectComps.year = 2026; expectComps.month = 1; expectComps.day = 11
        expectComps.hour = 10; expectComps.minute = 0; expectComps.second = 0
        let expectedSunday = utcCalendar.date(from: expectComps)!

        #expect(next == expectedSunday)
    }
}
