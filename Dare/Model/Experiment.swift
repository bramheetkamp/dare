//
//  Experiment.swift
//  Dare
//
//  Pure, Firebase-free experiment-bucketing logic.
//  RemoteConfig wiring (to drive rollout %s remotely) lives in a future service layer;
//  hardcoded defaults work fine until then.
//

import Foundation

// MARK: - Experiment catalogue

/// All currently defined A/B experiments.
/// Add a new case here to introduce a new experiment flag.
/// A case's `key` (= `rawValue`) is the stable seed fed to the hash — never rename one.
enum Experiment: String, CaseIterable {
    /// Tests two home-screen layouts: grid-first vs. goal-hero-first.
    case homeLayoutGoalHeroFirst = "home_layout_goal_hero_first"

    var key: String { rawValue }
}

// MARK: - Bucket

/// Which arm of an A/B test the user is assigned to.
enum ExperimentBucket: String, Equatable {
    case control
    case treatment
}

// MARK: - Bucketer

/// Assigns users to experiment buckets deterministically from (uid, experiment key).
/// All logic is pure so it is fully unit-testable without Firebase or any SDK.
enum ExperimentBucketer {

    /// Assign `uid` to a bucket for `experiment` with `rolloutPct` percent in treatment.
    ///
    /// - Parameters:
    ///   - uid: The authenticated user identifier (stable, non-empty).
    ///   - experiment: Which experiment to evaluate.
    ///   - rolloutPct: 0–100 inclusive. 0 → always control; 100 → always treatment.
    /// - Returns: `.treatment` or `.control`.
    static func bucket(
        uid: String,
        experiment: Experiment,
        rolloutPct: Int
    ) -> ExperimentBucket {
        let pct = max(0, min(100, rolloutPct))
        guard pct > 0 else { return .control }
        guard pct < 100 else { return .treatment }

        let key = "\(uid):\(experiment.key)"
        let hash = stableHash(key)
        return Int(hash % 100) < pct ? .treatment : .control
    }

    // MARK: - Hash

    /// FNV-1a 32-bit hash — stable across Swift versions and platforms (no seed randomisation).
    static func stableHash(_ string: String) -> UInt32 {
        var hash: UInt32 = 2_166_136_261
        for byte in string.utf8 {
            hash ^= UInt32(byte)
            hash = hash &* 16_777_619
        }
        return hash
    }
}

// MARK: - Rollout configuration

/// Centralises experiment rollout percentages. Override at runtime via Remote Config later.
enum ExperimentRollout {
    /// Returns the configured rollout percentage (0–100) for `experiment`.
    /// Defaults are safe for production: all start at 0% until intentionally enabled.
    static func pct(for experiment: Experiment) -> Int {
        switch experiment {
        case .homeLayoutGoalHeroFirst:
            return 0   // disabled until the goal-hero layout is production-ready
        }
    }
}
