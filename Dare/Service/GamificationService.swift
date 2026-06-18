//
//  GamificationService.swift
//  Dare
//
//  Firestore plumbing for streaks and points. Pure math lives in Gamification.swift.
//

import FirebaseFirestore

struct GamificationService {
    private let db = Firestore.firestore()

    private func userDocument(_ uid: String) -> DocumentReference {
        db.collection("users").document(uid)
    }

    /// Records that the user opened the app today. On a *new* calendar day this advances the
    /// streak (or resets it if a day was missed), updates the longest streak, stamps
    /// `lastActiveAt`, and grants the daily check-in points. Same-day opens are a no-op.
    ///
    /// Freeze logic: if the streak would reset and the user holds at least one freeze token,
    /// the token is consumed and the streak is preserved. A freeze is earned at 7-day and
    /// every 30-day streak milestone.
    ///
    /// Calls back with the resulting current streak.
    func recordDailyActivity(uid: String, completion: ((Int) -> Void)? = nil) {
        let ref = userDocument(uid)

        ref.getDocument { snapshot, _ in
            let data = snapshot?.data() ?? [:]
            let lastActive = (data["lastActiveAt"] as? Timestamp)?.dateValue()
            let previousStreak = data["currentStreak"] as? Int ?? 0
            let longestStreak = data["longestStreak"] as? Int ?? 0
            let points = data["points"] as? Int ?? 0
            let currentFreezes = data["streakFreezeCount"] as? Int ?? 0

            guard StreakCalculator.isNewDay(lastActive: lastActive) else {
                completion?(previousStreak)
                return
            }

            let result = StreakCalculator.updatedStreakApplyingFreeze(
                previousStreak: previousStreak,
                lastActive: lastActive,
                freezesAvailable: currentFreezes
            )

            let newStreak = result.newStreak
            var newFreezes = currentFreezes
            if result.freezeConsumed {
                newFreezes = max(0, currentFreezes - 1)
            } else if StreakCalculator.earnsFreeze(newStreak: newStreak) {
                newFreezes = currentFreezes + 1
            }

            ref.updateData([
                "currentStreak": newStreak,
                "longestStreak": max(longestStreak, newStreak),
                "lastActiveAt": Timestamp(date: Date()),
                "points": points + PointEvent.dailyCheckIn.rawValue,
                "streakFreezeCount": newFreezes
            ]) { error in
                if let error = error {
                    print("DEBUG: Failed to record daily activity: \(error.localizedDescription)")
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
