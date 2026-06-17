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
}
