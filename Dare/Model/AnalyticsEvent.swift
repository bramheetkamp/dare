//
//  AnalyticsEvent.swift
//  Dare
//
//  Pure, Firebase-free analytics event definitions and screen-view debounce helper.
//  A real analytics provider (Firebase Analytics, Mixpanel, etc.) plugs in via
//  AnalyticsService without any changes here.
//

import Foundation

// MARK: - Event catalogue

/// All instrumented events in the Dare app. Associated values carry the minimal
/// context needed to measure each action — no PII.
enum AnalyticsEvent: Equatable {

    // MARK: Screen views
    case screenView(ScreenName)

    // MARK: Onboarding funnel
    case onboardingStarted
    case onboardingPageViewed(index: Int)
    case onboardingCompleted

    // MARK: Content actions
    case postCreated
    case postLiked
    case commentPosted
    case shareSheetOpened

    // MARK: Goals / journeys
    case goalJoined
    case goalProgressPosted

    // MARK: Gamification
    case streakIncremented(to: Int)
    case leveledUp(to: Int)
    case streakFreezeUsed
    case streakFreezeEarned

    // MARK: Deep linking
    case deepLinkOpened(route: String)

    // MARK: - Screen names

    enum ScreenName: String, CaseIterable {
        case feed        = "feed"
        case explore     = "explore"
        case profile     = "profile"
        case onboarding  = "onboarding"
        case goalDetail  = "goal_detail"
        case createPost  = "create_post"
        case comments    = "comments"
        case yearAgo     = "year_ago"
        case settings    = "settings"
    }

    // MARK: - Event name (analytics backend key)

    var name: String {
        switch self {
        case .screenView:           return "screen_view"
        case .onboardingStarted:    return "onboarding_started"
        case .onboardingPageViewed: return "onboarding_page_viewed"
        case .onboardingCompleted:  return "onboarding_completed"
        case .postCreated:          return "post_created"
        case .postLiked:            return "post_liked"
        case .commentPosted:        return "comment_posted"
        case .shareSheetOpened:     return "share_sheet_opened"
        case .goalJoined:           return "goal_joined"
        case .goalProgressPosted:   return "goal_progress_posted"
        case .streakIncremented:    return "streak_incremented"
        case .leveledUp:            return "leveled_up"
        case .streakFreezeUsed:     return "streak_freeze_used"
        case .streakFreezeEarned:   return "streak_freeze_earned"
        case .deepLinkOpened:       return "deep_link_opened"
        }
    }

    /// Flat string → string parameters for a generic analytics provider.
    var parameters: [String: String] {
        switch self {
        case .screenView(let screen):
            return ["screen_name": screen.rawValue]
        case .onboardingPageViewed(let index):
            return ["page_index": "\(index)"]
        case .streakIncremented(let value):
            return ["streak": "\(value)"]
        case .leveledUp(let level):
            return ["level": "\(level)"]
        case .deepLinkOpened(let route):
            return ["route": route]
        default:
            return [:]
        }
    }
}

// MARK: - Screen-view debounce helper

/// Pure value type that decides whether a `.screenView` event should fire.
/// Guards against duplicate firings when a view's `onAppear` is called rapidly
/// (e.g. tab switches, navigation pushes/pops).
struct ScreenTracker {
    private(set) var lastScreen: AnalyticsEvent.ScreenName?
    private(set) var lastFiredAt: Date?

    /// Returns `true` when a screen-view event should be tracked.
    /// Suppressed only when the exact same screen fired within `minInterval` seconds.
    func shouldFire(
        screen: AnalyticsEvent.ScreenName,
        now: Date = Date(),
        minInterval: TimeInterval = 1.0
    ) -> Bool {
        guard let lastScreen, lastScreen == screen, let lastFiredAt else {
            return true
        }
        return now.timeIntervalSince(lastFiredAt) >= minInterval
    }

    /// Record that a screen-view event was fired.
    mutating func didFire(screen: AnalyticsEvent.ScreenName, at date: Date = Date()) {
        lastScreen = screen
        lastFiredAt = date
    }
}
