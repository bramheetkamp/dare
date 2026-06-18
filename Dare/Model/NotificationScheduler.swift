//
//  NotificationScheduler.swift
//  Dare
//
//  Pure date arithmetic for the weekly ritual notification — no UserNotifications import
//  so this stays fully unit-testable. The actual scheduling lives in NotificationService.swift.
//

import Foundation

enum NotificationScheduler {

    /// Returns the next calendar occurrence of `weekday` at `hour:minute` local time
    /// that is strictly *after* `now`. Never returns a date in the past.
    ///
    /// - Parameters:
    ///   - now: Reference date (defaults to `Date()`).
    ///   - weekday: ISO weekday where 1 = Sunday, 7 = Saturday (Calendar.current convention).
    ///   - hour: Hour of day in the 24-hour clock (0–23).
    ///   - minute: Minute (0–59).
    ///   - calendar: Calendar to use for date arithmetic (injectable for tests).
    static func nextRitualDate(
        after now: Date = Date(),
        weekday: Int = 1,   // Sunday
        hour: Int = 10,
        minute: Int = 0,
        calendar: Calendar = .current
    ) -> Date {
        var components = DateComponents()
        components.weekday = weekday
        components.hour = hour
        components.minute = minute
        components.second = 0

        if let next = calendar.nextDate(
            after: now,
            matching: components,
            matchingPolicy: .nextTime,
            direction: .forward
        ) {
            return next
        }

        // Fallback: advance exactly 7 days and snap to the hour (should never happen).
        let fallback = calendar.date(byAdding: .day, value: 7, to: now) ?? now.addingTimeInterval(7 * 86_400)
        return fallback
    }
}
