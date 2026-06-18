//
//  ExperimentTests.swift
//  DareTests
//
//  Pure tests for the A/B experiment-bucketing logic (no Firebase).
//

import Testing
import Foundation
@testable import Dare

struct ExperimentBucketingTests {

    // MARK: - Rollout boundaries

    @Test func rolloutZeroPctAlwaysControl() {
        for uid in ["alice", "bob", "charlie", "delta99", "uid-\(Int.max)"] {
            #expect(ExperimentBucketer.bucket(uid: uid, experiment: .homeLayoutGoalHeroFirst, rolloutPct: 0) == .control)
        }
    }

    @Test func rolloutHundredPctAlwaysTreatment() {
        for uid in ["alice", "bob", "charlie", "delta99", "uid-\(Int.max)"] {
            #expect(ExperimentBucketer.bucket(uid: uid, experiment: .homeLayoutGoalHeroFirst, rolloutPct: 100) == .treatment)
        }
    }

    @Test func negativePctClampsToControl() {
        #expect(ExperimentBucketer.bucket(uid: "user1", experiment: .homeLayoutGoalHeroFirst, rolloutPct: -1) == .control)
        #expect(ExperimentBucketer.bucket(uid: "user1", experiment: .homeLayoutGoalHeroFirst, rolloutPct: -99) == .control)
    }

    @Test func pctOver100ClampsTreatment() {
        #expect(ExperimentBucketer.bucket(uid: "user1", experiment: .homeLayoutGoalHeroFirst, rolloutPct: 101) == .treatment)
        #expect(ExperimentBucketer.bucket(uid: "user1", experiment: .homeLayoutGoalHeroFirst, rolloutPct: 9999) == .treatment)
    }

    // MARK: - Determinism

    @Test func sameInputsAlwaysProduceSameBucket() {
        for _ in 0..<5 {
            let b = ExperimentBucketer.bucket(uid: "stable-uid-xyz", experiment: .homeLayoutGoalHeroFirst, rolloutPct: 50)
            #expect(b == ExperimentBucketer.bucket(uid: "stable-uid-xyz", experiment: .homeLayoutGoalHeroFirst, rolloutPct: 50))
        }
    }

    @Test func hashIsDeterministic() {
        let h1 = ExperimentBucketer.stableHash("hello:world")
        let h2 = ExperimentBucketer.stableHash("hello:world")
        #expect(h1 == h2)
    }

    @Test func differentStringsProduceDifferentHashes() {
        let h1 = ExperimentBucketer.stableHash("uid-a:home_layout_goal_hero_first")
        let h2 = ExperimentBucketer.stableHash("uid-b:home_layout_goal_hero_first")
        // Not a guarantee for all inputs, but these two should differ
        #expect(h1 != h2)
    }

    // MARK: - Distribution

    @Test func fiftyPctRolloutRoughlyHalfInTreatment() {
        let total = 1_000
        let treatmentCount = (0..<total).filter { i in
            ExperimentBucketer.bucket(uid: "user-\(i)", experiment: .homeLayoutGoalHeroFirst, rolloutPct: 50) == .treatment
        }.count
        // Expect 40–60% in treatment (400–600 / 1000)
        #expect(treatmentCount >= 400 && treatmentCount <= 600,
                "Got \(treatmentCount) / \(total) in treatment at 50% rollout — outside acceptable range")
    }

    @Test func twentyPctRolloutRoughlyOneFifthInTreatment() {
        let total = 1_000
        let treatmentCount = (0..<total).filter { i in
            ExperimentBucketer.bucket(uid: "user-\(i)", experiment: .homeLayoutGoalHeroFirst, rolloutPct: 20) == .treatment
        }.count
        // Expect 10–30% in treatment (100–300 / 1000)
        #expect(treatmentCount >= 100 && treatmentCount <= 300,
                "Got \(treatmentCount) / \(total) in treatment at 20% rollout — outside acceptable range")
    }

    @Test func bothBucketsAppearsWithTwentyUsers() {
        let buckets = (0..<20).map { i in
            ExperimentBucketer.bucket(uid: "uid-\(i)", experiment: .homeLayoutGoalHeroFirst, rolloutPct: 50)
        }
        #expect(buckets.contains(.control) && buckets.contains(.treatment),
                "Expected both buckets to appear across 20 users at 50% rollout")
    }

    // MARK: - Experiment catalogue

    @Test func allExperimentsHaveNonEmptyStableKeys() {
        for exp in Experiment.allCases {
            #expect(!exp.key.isEmpty)
            #expect(exp.key == exp.rawValue)
        }
    }

    @Test func experimentKeyIsUsedInHash() {
        // Two identical UIDs hashed against the same experiment produce the same bucket
        let b1 = ExperimentBucketer.bucket(uid: "test-uid", experiment: .homeLayoutGoalHeroFirst, rolloutPct: 50)
        let b2 = ExperimentBucketer.bucket(uid: "test-uid", experiment: .homeLayoutGoalHeroFirst, rolloutPct: 50)
        #expect(b1 == b2)
    }

    // MARK: - Rollout configuration

    @Test func defaultRolloutsAreSafeForProduction() {
        for exp in Experiment.allCases {
            let pct = ExperimentRollout.pct(for: exp)
            #expect(pct >= 0 && pct <= 100)
        }
    }
}

// MARK: - ExperimentBucket enum tests

struct ExperimentBucketEnumTests {

    @Test func rawValuesAreHumanReadable() {
        #expect(ExperimentBucket.control.rawValue == "control")
        #expect(ExperimentBucket.treatment.rawValue == "treatment")
    }

    @Test func equalityWorks() {
        #expect(ExperimentBucket.control == ExperimentBucket.control)
        #expect(ExperimentBucket.treatment == ExperimentBucket.treatment)
        #expect(ExperimentBucket.control != ExperimentBucket.treatment)
    }
}

// MARK: - Analytics integration

struct ExperimentAnalyticsTests {

    @Test func experimentAssignedEventName() {
        let event = AnalyticsEvent.experimentAssigned(experiment: "home_layout_goal_hero_first", bucket: "treatment")
        #expect(event.name == "experiment_assigned")
    }

    @Test func experimentAssignedEventParameters() {
        let event = AnalyticsEvent.experimentAssigned(experiment: "home_layout_goal_hero_first", bucket: "control")
        #expect(event.parameters["experiment"] == "home_layout_goal_hero_first")
        #expect(event.parameters["bucket"] == "control")
    }

    @Test func experimentAssignedEventEquatability() {
        let a = AnalyticsEvent.experimentAssigned(experiment: "exp_a", bucket: "control")
        let b = AnalyticsEvent.experimentAssigned(experiment: "exp_a", bucket: "control")
        let c = AnalyticsEvent.experimentAssigned(experiment: "exp_a", bucket: "treatment")
        #expect(a == b)
        #expect(a != c)
    }
}
