//
//  EvictionPolicyTests.swift
//  DareTests
//
//  Pure tests for EvictionPolicy — no Firebase, no SwiftUI.
//

import Testing
@testable import Dare

struct EvictionPolicyTests {

    // MARK: - No-op cases (store should be unchanged)

    @Test func emptyArrayIsReturnedUnchanged() {
        let policy = EvictionPolicy(maxSize: 10)
        let result = policy.apply(to: [Int]())
        #expect(result.isEmpty)
    }

    @Test func arrayUnderLimitIsReturnedUnchanged() {
        let policy = EvictionPolicy(maxSize: 5)
        let items = [1, 2, 3]
        #expect(policy.apply(to: items) == items)
    }

    @Test func arrayAtExactLimitIsReturnedUnchanged() {
        let policy = EvictionPolicy(maxSize: 3)
        let items = [10, 20, 30]
        #expect(policy.apply(to: items) == items)
    }

    // MARK: - Eviction cases

    @Test func oneOverLimitEvictsOldestEntry() {
        let policy = EvictionPolicy(maxSize: 3)
        let items = ["a", "b", "c", "d"]   // 4 items, oldest = "a"
        let result = policy.apply(to: items)
        #expect(result == ["b", "c", "d"])
    }

    @Test func manyOverLimitTrimsToMaxSize() {
        let policy = EvictionPolicy(maxSize: 3)
        let items = Array(1...10)
        let result = policy.apply(to: items)
        #expect(result.count == 3)
        #expect(result == [8, 9, 10])
    }

    @Test func trimPreservesNewestNotOldest() {
        let policy = EvictionPolicy(maxSize: 2)
        let items = ["old1", "old2", "old3", "newest"]
        let result = policy.apply(to: items)
        #expect(result == ["old3", "newest"])
        #expect(!result.contains("old1"))
        #expect(!result.contains("old2"))
    }

    // MARK: - Edge / degenerate cases

    @Test func maxSizeOfOneKeepsOnlyNewest() {
        let policy = EvictionPolicy(maxSize: 1)
        let items = [100, 200, 300]
        #expect(policy.apply(to: items) == [300])
    }

    @Test func maxSizeZeroReturnsEmpty() {
        let policy = EvictionPolicy(maxSize: 0)
        let items = [1, 2, 3]
        #expect(policy.apply(to: items).isEmpty)
    }

    @Test func worksWithStringItems() {
        let policy = EvictionPolicy(maxSize: 2)
        let items = ["alpha", "beta", "gamma"]
        #expect(policy.apply(to: items) == ["beta", "gamma"])
    }

    @Test func worksWithSingleItemAtLimit() {
        let policy = EvictionPolicy(maxSize: 1)
        #expect(policy.apply(to: ["only"]) == ["only"])
    }
}
