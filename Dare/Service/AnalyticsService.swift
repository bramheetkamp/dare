//
//  AnalyticsService.swift
//  Dare
//
//  Analytics provider protocol + built-in implementations.
//  A real SDK (Firebase Analytics, Mixpanel, etc.) slots in by conforming to
//  AnalyticsService — no call sites change.
//

import Foundation
import OSLog

// MARK: - Protocol

protocol AnalyticsService: AnyObject {
    func track(_ event: AnalyticsEvent)
}

// MARK: - No-op (default / unit-test stand-in)

/// Silent implementation used as the environment default and in unit tests
/// that don't care which events are fired.
final class NoOpAnalyticsService: AnalyticsService {
    func track(_ event: AnalyticsEvent) {}
}

// MARK: - Console (development / debug)

/// Logs every event to the unified logging system. Inject at app launch.
final class ConsoleAnalyticsService: AnalyticsService {
    private let logger = Logger(subsystem: "com.dare", category: "analytics")

    func track(_ event: AnalyticsEvent) {
        if event.parameters.isEmpty {
            logger.debug("[analytics] \(event.name)")
        } else {
            logger.debug("[analytics] \(event.name) \(event.parameters)")
        }
    }
}
