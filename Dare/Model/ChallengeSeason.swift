//
//  ChallengeSeason.swift
//  Dare
//
//  Pure, Firebase-free logic for time-boxed challenge "seasons". Firestore plumbing
//  (reading/writing startsAt / endsAt) lives in ChallengeService.swift.
//

import Foundation

/// Pure functions for reasoning about a challenge season window.
///
/// Every function accepts `Date?` parameters (not Firestore `Timestamp`s) so the logic is
/// fully testable without Firebase. Convert at the view-model / service boundary using
/// `Challenge.startDate` / `Challenge.endDate`.
enum ChallengeSeasonLogic {

    // MARK: - Active / inactive

    /// Whether the season is active at `now`.
    ///
    /// | start  | end    | behaviour                                     |
    /// |--------|--------|-----------------------------------------------|
    /// | nil    | nil    | Always active (legacy goal — no window set).   |
    /// | set    | nil    | Active once `start` is reached.               |
    /// | nil    | set    | Active until `end` passes.                    |
    /// | set    | set    | Active within `[start, end]`.                  |
    static func isActive(start: Date?, end: Date?, at now: Date = Date()) -> Bool {
        switch (start, end) {
        case (nil, nil):
            return true
        case (let s?, nil):
            return now >= s
        case (nil, let e?):
            return now <= e
        case (let s?, let e?):
            return now >= s && now <= e
        }
    }

    // MARK: - Days remaining

    /// Calendar days remaining until `end` (inclusive of today), or `nil` when no end date
    /// is set. Returns 0 when the season has already ended.
    static func daysRemaining(end: Date?, from now: Date = Date(), calendar: Calendar = .current) -> Int? {
        guard let end else { return nil }
        let startOfNow = calendar.startOfDay(for: now)
        let startOfEnd = calendar.startOfDay(for: end)
        let components = calendar.dateComponents([.day], from: startOfNow, to: startOfEnd)
        return max(0, components.day ?? 0)
    }

    // MARK: - Progress fraction

    /// A 0…1 fraction representing how far through the season `now` is.
    /// Returns `nil` when `start` or `end` is absent — without both anchors the fraction is
    /// undefined. Clamped to `[0, 1]` so values before start return 0 and after end return 1.
    static func progressFraction(start: Date?, end: Date?, at now: Date = Date()) -> Double? {
        guard let start, let end else { return nil }
        let total = end.timeIntervalSince(start)
        guard total > 0 else { return 1.0 }   // zero-duration season is "done"
        let elapsed = now.timeIntervalSince(start)
        return min(1.0, max(0.0, elapsed / total))
    }

    // MARK: - Display label

    /// A short human-readable label for the season state, e.g. "3 days left" or "Ongoing".
    /// Returns `nil` when there is no end date (runs indefinitely).
    static func statusLabel(end: Date?, from now: Date = Date(), calendar: Calendar = .current) -> String? {
        guard let days = daysRemaining(end: end, from: now, calendar: calendar) else { return nil }
        switch days {
        case 0:  return "Last day!"
        case 1:  return "1 day left"
        default: return "\(days) days left"
        }
    }
}
