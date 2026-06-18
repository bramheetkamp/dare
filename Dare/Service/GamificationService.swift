//
//  GamificationService.swift
//  Dare
//
//  Firestore plumbing for streaks and points. Pure math lives in Gamification.swift.
//
//  Streak ownership change: `recordDailyActivity` only stamps `lastActiveAt` and
//  awards the daily check-in points. The *streak* now advances exclusively via
//  `recordWeeklyGoalActivity`, which is called when the user posts a goal update.
//  This aligns with the product vision: "the streak counts weekly goal-updates,
//  not daily opens."
//

import FirebaseFirestore

struct GamificationService {
    private let db = Firestore.firestore()

    private func userDocument(_ uid: String) -> DocumentReference {
        db.collection("users").document(uid)
    }

    /// Records that the user opened the app today. Awards the daily check-in points
    /// on the first open of each calendar day and stamps `lastActiveAt`. Does NOT
    /// advance the streak — that is driven by `recordWeeklyGoalActivity`.
    func recordDailyActivity(uid: String, completion: ((Int) -> Void)? = nil) {
        let ref = userDocument(uid)

        ref.getDocument { snapshot, _ in
            let data = snapshot?.data() ?? [:]
            let lastActive = (data["lastActiveAt"] as? Timestamp)?.dateValue()
            let currentStreak = data["currentStreak"] as? Int ?? 0
            let points = data["points"] as? Int ?? 0

            guard StreakCalculator.isNewDay(lastActive: lastActive) else {
                completion?(currentStreak)
                return
            }

            ref.updateData([
                "lastActiveAt": Timestamp(date: Date()),
                "points": points + PointEvent.dailyCheckIn.rawValue
            ]) { error in
                if let error = error {
                    print("DEBUG: Failed to record daily activity: \(error.localizedDescription)")
                }
                completion?(currentStreak)
            }
        }
    }

    /// Records a goal-update post by the user. On the first post of a new ISO week
    /// this advances the weekly streak, handles freeze tokens, and awards
    /// `weeklyGoalPost` bonus points. Same-week repeat posts are a no-op here (base
    /// post points are awarded separately via `awardPoints(.createPost)`).
    ///
    /// Call this once per successful post upload (from `PostUploadService`).
    func recordWeeklyGoalActivity(uid: String, completion: ((Int) -> Void)? = nil) {
        let ref = userDocument(uid)

        ref.getDocument { snapshot, _ in
            let data = snapshot?.data() ?? [:]
            let lastGoalUpdate = (data["lastGoalUpdateAt"] as? Timestamp)?.dateValue()
            let previousStreak = data["currentStreak"] as? Int ?? 0
            let longestStreak = data["longestStreak"] as? Int ?? 0
            let points = data["points"] as? Int ?? 0
            let currentFreezes = data["streakFreezeCount"] as? Int ?? 0

            // Only advance the streak once per ISO week.
            guard StreakCalculator.isNewWeek(lastGoalUpdate: lastGoalUpdate) else {
                completion?(previousStreak)
                return
            }

            let result = StreakCalculator.updatedWeeklyStreakApplyingFreeze(
                previousStreak: previousStreak,
                lastGoalUpdate: lastGoalUpdate,
                freezesAvailable: currentFreezes
            )

            let newStreak = result.newStreak
            var newFreezes = currentFreezes
            if result.freezeConsumed {
                newFreezes = max(0, currentFreezes - 1)
            } else if StreakCalculator.earnsWeeklyFreeze(newStreak: newStreak) {
                newFreezes = currentFreezes + 1
            }

            ref.updateData([
                "currentStreak": newStreak,
                "longestStreak": max(longestStreak, newStreak),
                "lastGoalUpdateAt": Timestamp(date: Date()),
                "points": points + PointEvent.weeklyGoalPost.rawValue,
                "streakFreezeCount": newFreezes
            ]) { error in
                if let error = error {
                    print("DEBUG: Failed to record weekly goal activity: \(error.localizedDescription)")
                }
                completion?(newStreak)
            }
        }
    }

    /// Atomically grants the points for an action (post created, challenge completed, etc.).
    func awardPoints(uid: String, for event: PointEvent, completion: (() -> Void)? = nil) {
        userDocument(uid).updateData([
            "points": FieldValue.increment(Int64(event.rawValue))
        ]) { _ in
            completion?()
        }
    }
}
