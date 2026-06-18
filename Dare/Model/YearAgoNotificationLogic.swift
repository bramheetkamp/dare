//
//  YearAgoNotificationLogic.swift
//  Dare
//
//  Pure, Firebase-free logic for selecting which post to surface in the
//  "you, a year ago" weekly notification. Posts are passed as lightweight
//  (id, date) pairs so there is no Firebase import here — fully testable.
//

import Foundation

enum YearAgoNotificationLogic {

    /// Days either side of "one year ago today" that still qualifies as a memory.
    static let windowDays = 14

    // MARK: - Post selection

    /// ID of the post whose date is closest to `reference − 1 year`, within
    /// ±`windowDays`. Returns `nil` when the window is empty or the array is empty.
    static func bestPostId(
        from posts: [(id: String, date: Date)],
        reference: Date = Date(),
        windowDays: Int = windowDays,
        calendar: Calendar = .current
    ) -> String? {
        guard
            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: reference),
            let start      = calendar.date(byAdding: .day, value: -windowDays, to: oneYearAgo),
            let end        = calendar.date(byAdding: .day, value:  windowDays, to: oneYearAgo)
        else { return nil }

        return posts
            .filter { $0.date >= start && $0.date <= end }
            .min {
                abs($0.date.distance(to: oneYearAgo)) < abs($1.date.distance(to: oneYearAgo))
            }?
            .id
    }

    // MARK: - Notification copy

    /// Builds a friendly notification body. When `note` is non-empty it is quoted;
    /// otherwise a generic prompt is returned.
    static func notificationBody(note: String?) -> String {
        if let n = note, !n.isEmpty {
            return "A year ago you posted: \"\(n)\" — look how far you've come 🏆"
        }
        return "Take a look at what you were working on a year ago 🏆"
    }

    // MARK: - Post → lightweight pair conversion

    /// Converts a `PublicPost` array into the (id, date) pairs expected by `bestPostId`.
    /// Placed here (not in the model) so this file stays the single source of the mapping
    /// and callers do not need to know about `Timestamp`.
    static func pairs(from posts: [PublicPost]) -> [(id: String, date: Date)] {
        posts.compactMap { post in
            guard let id = post.id else { return nil }
            return (id: id, date: post.timestamp.dateValue())
        }
    }
}
