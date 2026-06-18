//
//  Gamification.swift
//  Dare
//
//  Pure, Firebase-free gamification logic so it stays unit-testable.
//  Firestore plumbing lives in GamificationService.swift.
//

import Foundation

/// Decides how a user's daily streak evolves. All functions are pure so they can be tested
/// without Firebase by injecting `now`/`calendar`.
enum StreakCalculator {

    /// New streak value for activity happening at `now`, given the previous streak and the
    /// last day the user was active.
    /// - same calendar day  → unchanged (but at least 1)
    /// - exactly the next day → previous + 1
    /// - a gap of 2+ days, or no history → reset to 1
    static func updatedStreak(
        previousStreak: Int,
        lastActive: Date?,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        guard let lastActive else { return 1 }

        let startToday = calendar.startOfDay(for: now)
        let startLast = calendar.startOfDay(for: lastActive)
        let dayGap = calendar.dateComponents([.day], from: startLast, to: startToday).day ?? 0

        switch dayGap {
        case ..<0: return max(previousStreak, 1)   // clock skew / future date — don't punish
        case 0:    return max(previousStreak, 1)   // already counted today
        case 1:    return previousStreak + 1       // consecutive day
        default:   return 1                         // streak broken
        }
    }

    /// True when activity at `now` falls on a different calendar day than `lastActive`
    /// (i.e. the daily reward/streak update should run).
    static func isNewDay(
        lastActive: Date?,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Bool {
        guard let lastActive else { return true }
        return !calendar.isDate(lastActive, inSameDayAs: now)
    }
}

/// Maps a running point total to a level and progress within that level.
/// Level `n` spans `n * 100` points, so thresholds grow: L1 = 0, L2 = 100, L3 = 300, L4 = 600…
enum GamificationLevel {

    /// The level a given point total has reached (levels start at 1).
    static func level(for points: Int) -> Int {
        progress(for: points).level
    }

    /// Detailed progress: current `level`, points earned `into` the current level, and the
    /// `span` (points required to clear the current level).
    static func progress(for points: Int) -> (level: Int, into: Int, span: Int) {
        let safePoints = max(points, 0)
        var level = 1
        var threshold = 0
        while safePoints >= threshold + level * 100 {
            threshold += level * 100
            level += 1
        }
        return (level, safePoints - threshold, level * 100)
    }

    /// Fraction (0...1) of the way through the current level — handy for a progress bar.
    static func fractionIntoLevel(for points: Int) -> Double {
        let p = progress(for: points)
        guard p.span > 0 else { return 0 }
        return Double(p.into) / Double(p.span)
    }
}

// MARK: - Streak freeze

/// Outcome of a freeze-aware streak update.
struct StreakUpdateResult: Equatable {
    /// The streak value to persist.
    let newStreak: Int
    /// `true` when a freeze token was consumed to protect the streak from resetting.
    let freezeConsumed: Bool
}

extension StreakCalculator {

    /// Freeze-aware variant of `updatedStreak`. When the streak would otherwise reset (a
    /// gap of ≥ 2 days) and `freezesAvailable > 0`, the streak is preserved and
    /// `freezeConsumed` is `true`. A freeze bridges at most one missed period; a larger gap
    /// still resets to 1 even if freezes remain.
    static func updatedStreakApplyingFreeze(
        previousStreak: Int,
        lastActive: Date?,
        now: Date = Date(),
        calendar: Calendar = .current,
        freezesAvailable: Int
    ) -> StreakUpdateResult {
        guard let lastActive else {
            return StreakUpdateResult(newStreak: 1, freezeConsumed: false)
        }

        let startToday = calendar.startOfDay(for: now)
        let startLast = calendar.startOfDay(for: lastActive)
        let dayGap = calendar.dateComponents([.day], from: startLast, to: startToday).day ?? 0

        switch dayGap {
        case ..<0, 0:
            return StreakUpdateResult(newStreak: max(previousStreak, 1), freezeConsumed: false)
        case 1:
            return StreakUpdateResult(newStreak: previousStreak + 1, freezeConsumed: false)
        default:
            if freezesAvailable > 0 {
                return StreakUpdateResult(newStreak: max(previousStreak, 1), freezeConsumed: true)
            }
            return StreakUpdateResult(newStreak: 1, freezeConsumed: false)
        }
    }

    /// `true` when reaching `newStreak` earns the user a free freeze token:
    /// at the 7-day milestone and at every 30-day multiple thereafter.
    static func earnsFreeze(newStreak: Int) -> Bool {
        newStreak == 7 || (newStreak > 0 && newStreak % 30 == 0)
    }
}

// MARK: - Weekly streak (goal-update driven)
//
// The product vision: "the streak counts weekly goal-updates, not daily opens."
// These are pure helpers — no Firebase imports.

extension StreakCalculator {

    // Start of the ISO week (Monday) that contains `date`.
    private static func weekStart(for date: Date, calendar: Calendar) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: comps) ?? date
    }

    /// Number of full ISO weeks between `from` and `to` (negative if `to` is before `from`).
    static func weeksBetween(from: Date, to: Date, calendar: Calendar = .current) -> Int {
        let f = weekStart(for: from, calendar: calendar)
        let t = weekStart(for: to, calendar: calendar)
        return calendar.dateComponents([.weekOfYear], from: f, to: t).weekOfYear ?? 0
    }

    /// `true` when `now` falls in a different ISO week than `lastGoalUpdate`.
    static func isNewWeek(
        lastGoalUpdate: Date?,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Bool {
        guard let last = lastGoalUpdate else { return true }
        return weeksBetween(from: last, to: now, calendar: calendar) != 0
    }

    /// Weekly streak value after a goal update at `now`.
    /// - same ISO week  → unchanged (already counted)
    /// - next ISO week  → previous + 1
    /// - gap ≥ 2 weeks  → reset to 1
    /// - clock skew     → preserve, don't punish
    static func updatedWeeklyStreak(
        previousStreak: Int,
        lastGoalUpdate: Date?,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        guard let last = lastGoalUpdate else { return 1 }
        let gap = weeksBetween(from: last, to: now, calendar: calendar)
        switch gap {
        case ..<0: return max(previousStreak, 1)
        case 0:    return max(previousStreak, 1)
        case 1:    return previousStreak + 1
        default:   return 1
        }
    }

    /// Freeze-aware weekly streak update. A freeze bridges exactly one missed week.
    static func updatedWeeklyStreakApplyingFreeze(
        previousStreak: Int,
        lastGoalUpdate: Date?,
        now: Date = Date(),
        calendar: Calendar = .current,
        freezesAvailable: Int
    ) -> StreakUpdateResult {
        guard let last = lastGoalUpdate else {
            return StreakUpdateResult(newStreak: 1, freezeConsumed: false)
        }
        let gap = weeksBetween(from: last, to: now, calendar: calendar)
        switch gap {
        case ..<0, 0:
            return StreakUpdateResult(newStreak: max(previousStreak, 1), freezeConsumed: false)
        case 1:
            return StreakUpdateResult(newStreak: previousStreak + 1, freezeConsumed: false)
        default:
            if freezesAvailable > 0 {
                return StreakUpdateResult(newStreak: max(previousStreak, 1), freezeConsumed: true)
            }
            return StreakUpdateResult(newStreak: 1, freezeConsumed: false)
        }
    }

    /// A freeze token is earned at 4-week and every 12-week milestone.
    static func earnsWeeklyFreeze(newStreak: Int) -> Bool {
        newStreak == 4 || (newStreak > 0 && newStreak % 12 == 0)
    }
}

// MARK: - Point events

/// Point rewards for in-app actions. Raw values are the points granted.
enum PointEvent: Int {
    case dailyCheckIn = 5
    case receiveLike = 2
    case createPost = 25
    case completeChallenge = 30
    case createChallenge = 40
    /// Posting a goal update in a new week — the core streak-driving action.
    case weeklyGoalPost = 50
}

// MARK: - Achievements

/// A single achievement with its unlock state.
struct Achievement: Equatable {
    let id: String
    let title: String
    let description: String
    let icon: String        // SF Symbol name
    let isUnlocked: Bool
}

/// Static catalogue of achievements. Unlock evaluation is purely a function of
/// `points` and `longestStreak` — no Firebase dependency.
enum AchievementCatalog {

    private struct Template {
        let id: String
        let title: String
        let description: String
        let icon: String
        let unlock: (Int, Int) -> Bool   // (points, longestStreak) -> Bool
    }

    private static let templates: [Template] = [
        Template(id: "streak_3",    title: "Hat-trick",      description: "Keep a 3-week goal streak",   icon: "flame.fill",               unlock: { _, s in s >= 3 }),
        Template(id: "points_50",   title: "Getting Started", description: "Earn 50 points",              icon: "star.fill",                unlock: { p, _ in p >= 50 }),
        Template(id: "streak_7",    title: "On Fire",         description: "Keep a 7-week goal streak",   icon: "flame.circle.fill",        unlock: { _, s in s >= 7 }),
        Template(id: "points_100",  title: "Centurion",       description: "Earn 100 points",             icon: "100.circle.fill",          unlock: { p, _ in p >= 100 }),
        Template(id: "level_2",     title: "Level Up",        description: "Reach level 2",               icon: "arrow.up.circle.fill",     unlock: { p, _ in GamificationLevel.level(for: p) >= 2 }),
        Template(id: "streak_30",   title: "Consistent",      description: "Keep a 30-week goal streak",  icon: "calendar.badge.checkmark", unlock: { _, s in s >= 30 }),
        Template(id: "points_300",  title: "Dedicated",       description: "Earn 300 points",             icon: "chart.bar.fill",           unlock: { p, _ in p >= 300 }),
        Template(id: "points_500",  title: "High Scorer",     description: "Earn 500 points",             icon: "trophy.fill",              unlock: { p, _ in p >= 500 }),
        Template(id: "streak_100",  title: "Legendary",       description: "Keep a 100-week goal streak", icon: "crown.fill",               unlock: { _, s in s >= 100 }),
        Template(id: "points_1000", title: "Grand Master",    description: "Earn 1000 points",            icon: "medal.fill",               unlock: { p, _ in p >= 1000 }),
    ]

    /// All achievements with their unlock state for the given profile.
    static func achievements(points: Int, longestStreak: Int) -> [Achievement] {
        templates.map { t in
            Achievement(id: t.id, title: t.title, description: t.description,
                        icon: t.icon, isUnlocked: t.unlock(points, longestStreak))
        }
    }

    /// Number of unlocked achievements.
    static func unlockedCount(points: Int, longestStreak: Int) -> Int {
        templates.filter { $0.unlock(points, longestStreak) }.count
    }

    /// Total number of achievements in the catalogue.
    static var totalCount: Int { templates.count }
}
