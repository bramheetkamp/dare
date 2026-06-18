//
//  HapticsManager.swift
//  Dare
//
//  Thin wrappers around UIKit feedback generators. All methods are safe to call from
//  the main thread at any time — each creates a fresh generator to avoid stale state.
//

import UIKit

enum HapticsManager {

    // MARK: - Impact

    /// Light tap — used for low-stakes interactions (opening a sheet, small selection).
    static func lightTap() {
        let g = UIImpactFeedbackGenerator(style: .light)
        g.prepare()
        g.impactOccurred()
    }

    /// Medium tap — used for significant taps like the like button.
    static func tap() {
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.prepare()
        g.impactOccurred()
    }

    /// Heavy tap — used for high-impact moments like completing a challenge.
    static func heavyTap() {
        let g = UIImpactFeedbackGenerator(style: .heavy)
        g.prepare()
        g.impactOccurred()
    }

    // MARK: - Notification

    /// Fired when an action succeeds (post uploaded, streak incremented, level up).
    static func success() {
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.success)
    }

    /// Fired when an action fails or is blocked (validation error, network issue).
    static func error() {
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.error)
    }
}
