//
//  View+Analytics.swift
//  Dare
//
//  SwiftUI environment key + `.trackScreen(_:)` modifier + `.analyticsService(_:)` injector.
//

import SwiftUI

// MARK: - Environment key

private struct AnalyticsTrackKey: EnvironmentKey {
    static let defaultValue: (AnalyticsEvent) -> Void = { _ in }
}

extension EnvironmentValues {
    /// The current analytics tracking closure. Defaults to a no-op so views
    /// never need to guard against a nil service.
    var trackAnalyticsEvent: (AnalyticsEvent) -> Void {
        get { self[AnalyticsTrackKey.self] }
        set { self[AnalyticsTrackKey.self] = newValue }
    }
}

// MARK: - Screen-view modifier

private struct TrackScreenModifier: ViewModifier {
    let screen: AnalyticsEvent.ScreenName
    @Environment(\.trackAnalyticsEvent) private var track
    @State private var tracker = ScreenTracker()

    func body(content: Content) -> some View {
        content.onAppear {
            if tracker.shouldFire(screen: screen) {
                track(.screenView(screen))
                tracker.didFire(screen: screen)
            }
        }
    }
}

extension View {
    /// Fires a `.screenView` analytics event when this view appears.
    /// Built-in debounce prevents double-firing on rapid reappear cycles.
    func trackScreen(_ screen: AnalyticsEvent.ScreenName) -> some View {
        modifier(TrackScreenModifier(screen: screen))
    }

    /// Injects an `AnalyticsService` into the SwiftUI environment for the
    /// view hierarchy below. Call once at the root (`ContentView` or `DareApp`).
    func analyticsService<S: AnalyticsService>(_ service: S) -> some View {
        let track: (AnalyticsEvent) -> Void = { service.track($0) }
        return environment(\.trackAnalyticsEvent, track)
    }
}
