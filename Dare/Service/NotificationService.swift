//
//  NotificationService.swift
//  Dare
//
//  Thin wrapper around UNUserNotificationCenter for the weekly ritual nudge.
//  Pure scheduling logic lives in NotificationScheduler (Model/) so it stays testable.
//

import UserNotifications
import Foundation

struct NotificationService {

    static let weeklyRitualID = "com.dare.weeklyRitual"

    // MARK: - Permission

    /// Requests notification permission and returns whether it was granted.
    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Current authorization status without prompting the user.
    func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    // MARK: - Weekly ritual

    /// Schedules (or rescheduled) a repeating weekly notification for Sunday 10 am local time.
    /// Safe to call multiple times — cancels the previous request first.
    func scheduleWeeklyRitual() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized ||
                  settings.authorizationStatus == .provisional else { return }

            let content = UNMutableNotificationContent()
            content.title = "Time to check in 🔥"
            content.body = "Share a quick update on your goal and keep your streak alive."
            content.sound = .default

            // Fire once a week on Sunday at 10:00 local — vision-aligned weekly ritual.
            let fireDate = NotificationScheduler.nextRitualDate()
            let matchComponents = Calendar.current.dateComponents(
                [.weekday, .hour, .minute],
                from: fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: matchComponents, repeats: true)

            let request = UNNotificationRequest(
                identifier: Self.weeklyRitualID,
                content: content,
                trigger: trigger
            )

            center.removePendingNotificationRequests(withIdentifiers: [Self.weeklyRitualID])
            center.add(request)
        }
    }

    /// Cancels the scheduled weekly ritual notification.
    func cancelWeeklyRitual() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.weeklyRitualID])
    }

    /// Returns `true` if the weekly ritual notification is currently pending.
    func hasScheduledRitual() async -> Bool {
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return pending.contains { $0.identifier == Self.weeklyRitualID }
    }

    // MARK: - "You, a year ago" reminder

    static let yearAgoReminderID = "com.dare.yearAgoReminder"

    /// Schedules (or reschedules) a weekly "you, a year ago" notification that fires every
    /// Sunday at 09:00 local time — 1 hour before the ritual nudge so it doesn't compete.
    /// The `postId` is stored in `userInfo` so the app can deep-link to the post when the
    /// user taps the notification. Safe to call multiple times.
    func scheduleYearAgoReminder(postId: String, note: String?) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized ||
                  settings.authorizationStatus == .provisional else { return }

            let content = UNMutableNotificationContent()
            content.title = "You, a year ago 🕰️"
            content.body = YearAgoNotificationLogic.notificationBody(note: note)
            content.sound = .default
            content.userInfo = ["postId": postId]

            var comps = DateComponents()
            comps.weekday = 1  // Sunday
            comps.hour    = 9
            comps.minute  = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

            let request = UNNotificationRequest(
                identifier: Self.yearAgoReminderID,
                content: content,
                trigger: trigger
            )
            center.removePendingNotificationRequests(withIdentifiers: [Self.yearAgoReminderID])
            center.add(request)
        }
    }

    /// Cancels the "you, a year ago" reminder — call when the user has no memories or
    /// has disabled the notification type.
    func cancelYearAgoReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.yearAgoReminderID])
    }

    /// Returns `true` if the year-ago reminder is currently pending.
    func hasScheduledYearAgoReminder() async -> Bool {
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return pending.contains { $0.identifier == Self.yearAgoReminderID }
    }
}
