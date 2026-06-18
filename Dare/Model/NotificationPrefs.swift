//
//  NotificationPrefs.swift
//  Dare
//
//  Pure model for per-user notification preferences.
//  Stored as a nested map ("notificationPrefs") in the Firestore user document.
//  Adding new optional fields is backwards-compatible — old documents decode missing
//  fields to the default init value via the custom decoder below.
//

import Foundation

struct NotificationPrefs: Codable, Equatable, Hashable {

    /// Whether the user wants the weekly goal-update nudge (Sunday 10 am).
    /// Defaults to `true` for new and pre-existing users who haven't touched the setting.
    var weeklyRitual: Bool

    init(weeklyRitual: Bool = true) {
        self.weeklyRitual = weeklyRitual
    }

    // Custom decoder: missing keys fall back to the same defaults as init().
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        weeklyRitual = (try? c.decode(Bool.self, forKey: .weeklyRitual)) ?? true
    }
}

extension NotificationPrefs {
    /// Returns a copy with the given field changed.
    func withWeeklyRitual(_ enabled: Bool) -> NotificationPrefs {
        var copy = self
        copy.weeklyRitual = enabled
        return copy
    }

    /// Firestore field key prefix used by `UserService.updateNotificationPrefs`.
    static let firestoreKey = "notificationPrefs"
}
