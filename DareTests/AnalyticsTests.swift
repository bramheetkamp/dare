//
//  AnalyticsTests.swift
//  DareTests
//
//  Pure tests for AnalyticsEvent definitions and ScreenTracker debounce logic (no Firebase).
//

import Testing
import Foundation
@testable import Dare

// MARK: - AnalyticsEvent tests

struct AnalyticsEventTests {

    // MARK: Event name mapping

    @Test func screenViewName() {
        #expect(AnalyticsEvent.screenView(.feed).name == "screen_view")
    }

    @Test func onboardingEventNames() {
        #expect(AnalyticsEvent.onboardingStarted.name == "onboarding_started")
        #expect(AnalyticsEvent.onboardingPageViewed(index: 0).name == "onboarding_page_viewed")
        #expect(AnalyticsEvent.onboardingCompleted.name == "onboarding_completed")
    }

    @Test func contentEventNames() {
        #expect(AnalyticsEvent.postCreated.name == "post_created")
        #expect(AnalyticsEvent.postLiked.name == "post_liked")
        #expect(AnalyticsEvent.commentPosted.name == "comment_posted")
        #expect(AnalyticsEvent.shareSheetOpened.name == "share_sheet_opened")
    }

    @Test func gamificationEventNames() {
        #expect(AnalyticsEvent.streakIncremented(to: 5).name == "streak_incremented")
        #expect(AnalyticsEvent.leveledUp(to: 2).name == "leveled_up")
        #expect(AnalyticsEvent.streakFreezeUsed.name == "streak_freeze_used")
        #expect(AnalyticsEvent.streakFreezeEarned.name == "streak_freeze_earned")
    }

    @Test func deepLinkEventName() {
        #expect(AnalyticsEvent.deepLinkOpened(route: "challenge").name == "deep_link_opened")
    }

    // MARK: Parameters

    @Test func screenViewParameterContainsScreenName() {
        #expect(AnalyticsEvent.screenView(.feed).parameters == ["screen_name": "feed"])
        #expect(AnalyticsEvent.screenView(.explore).parameters == ["screen_name": "explore"])
    }

    @Test func onboardingPageParameterContainsIndex() {
        #expect(AnalyticsEvent.onboardingPageViewed(index: 2).parameters == ["page_index": "2"])
    }

    @Test func streakIncrementedParameterContainsValue() {
        #expect(AnalyticsEvent.streakIncremented(to: 7).parameters == ["streak": "7"])
    }

    @Test func leveledUpParameterContainsLevel() {
        #expect(AnalyticsEvent.leveledUp(to: 3).parameters == ["level": "3"])
    }

    @Test func deepLinkParameterContainsRoute() {
        #expect(AnalyticsEvent.deepLinkOpened(route: "post").parameters == ["route": "post"])
    }

    @Test func parameterlessEventsReturnEmpty() {
        let events: [AnalyticsEvent] = [
            .onboardingStarted, .onboardingCompleted,
            .postCreated, .postLiked, .commentPosted, .shareSheetOpened,
            .goalJoined, .goalProgressPosted,
            .streakFreezeUsed, .streakFreezeEarned
        ]
        for event in events {
            #expect(event.parameters.isEmpty, "Expected no parameters for '\(event.name)'")
        }
    }

    // MARK: Equatable

    @Test func sameScreenNamesAreEqual() {
        #expect(AnalyticsEvent.screenView(.feed) == AnalyticsEvent.screenView(.feed))
    }

    @Test func differentScreenNamesAreNotEqual() {
        #expect(AnalyticsEvent.screenView(.feed) != AnalyticsEvent.screenView(.explore))
    }

    @Test func pageViewedIndexEquality() {
        #expect(AnalyticsEvent.onboardingPageViewed(index: 1) == AnalyticsEvent.onboardingPageViewed(index: 1))
        #expect(AnalyticsEvent.onboardingPageViewed(index: 1) != AnalyticsEvent.onboardingPageViewed(index: 2))
    }

    @Test func differentEventTypesAreNotEqual() {
        #expect(AnalyticsEvent.onboardingStarted != AnalyticsEvent.onboardingCompleted)
    }

    // MARK: ScreenName raw values

    @Test func allScreenNamesHaveNonEmptyRawValues() {
        for screen in AnalyticsEvent.ScreenName.allCases {
            #expect(!screen.rawValue.isEmpty, "Empty rawValue for screen '\(screen)'")
        }
    }

    @Test func screenNameRawValuesUseSnakeCase() {
        for screen in AnalyticsEvent.ScreenName.allCases {
            let hasUppercase = screen.rawValue.contains { $0.isUppercase }
            #expect(!hasUppercase, "rawValue '\(screen.rawValue)' should be snake_case")
        }
    }
}

// MARK: - ScreenTracker tests

struct ScreenTrackerTests {

    private func at(_ interval: TimeInterval) -> Date {
        Date(timeIntervalSinceReferenceDate: interval)
    }

    @Test func freshTrackerAlwaysFires() {
        let tracker = ScreenTracker()
        #expect(tracker.shouldFire(screen: .feed, now: at(0)))
    }

    @Test func sameScreenWithinIntervalSuppressed() {
        var tracker = ScreenTracker()
        tracker.didFire(screen: .feed, at: at(0))
        #expect(!tracker.shouldFire(screen: .feed, now: at(0.5), minInterval: 1.0))
    }

    @Test func sameScreenAfterIntervalFires() {
        var tracker = ScreenTracker()
        tracker.didFire(screen: .feed, at: at(0))
        #expect(tracker.shouldFire(screen: .feed, now: at(2.0), minInterval: 1.0))
    }

    @Test func atExactBoundaryFires() {
        var tracker = ScreenTracker()
        tracker.didFire(screen: .profile, at: at(0))
        #expect(tracker.shouldFire(screen: .profile, now: at(1.0), minInterval: 1.0))
    }

    @Test func differentScreenAlwaysFires() {
        var tracker = ScreenTracker()
        tracker.didFire(screen: .feed, at: at(0))
        #expect(tracker.shouldFire(screen: .explore, now: at(0.1), minInterval: 1.0))
    }

    @Test func didFireUpdatesLastScreen() {
        var tracker = ScreenTracker()
        tracker.didFire(screen: .comments, at: at(0))
        #expect(tracker.lastScreen == .comments)
    }

    @Test func didFireUpdatesLastFiredAt() {
        var tracker = ScreenTracker()
        tracker.didFire(screen: .explore, at: at(99))
        #expect(tracker.lastFiredAt == at(99))
    }

    @Test func trackerStateIsValueType() {
        var tracker1 = ScreenTracker()
        tracker1.didFire(screen: .feed, at: at(0))
        var tracker2 = tracker1
        tracker2.didFire(screen: .explore, at: at(1))
        // tracker1 should be unchanged
        #expect(tracker1.lastScreen == .feed)
        #expect(tracker2.lastScreen == .explore)
    }

    @Test func zeroMinIntervalAlwaysFires() {
        var tracker = ScreenTracker()
        tracker.didFire(screen: .feed, at: at(0))
        #expect(tracker.shouldFire(screen: .feed, now: at(0), minInterval: 0))
    }
}
