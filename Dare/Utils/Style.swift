//
//  Style.swift
//  Dare
//
//  Created by Bram Heetkamp on 02/10/2025.
//

import SwiftUI

/// Central design tokens for Dare. Prefer the semantic `Style.Typography` roles for text —
/// they scale with Dynamic Type while keeping weights consistent. Use the raw `FontSize` /
/// `FontWeight` scales only when you need a fixed, non-scaling size (e.g. emoji art, big numbers).
struct Style {

    // MARK: - Corner radius

    struct CornerRadius {
        static let small: CGFloat = 8
        static let big: CGFloat = 16
    }

    // MARK: - Spacing

    /// Shared spacing scale for padding and stack spacing — keeps gaps consistent.
    struct Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
    }

    // MARK: - Raw font scale (fixed sizes)

    /// Point sizes. `small`/`medium`/`large` are kept for existing call sites; new code should
    /// prefer `Style.Typography`, which scales with the user's text-size setting.
    struct FontSize {
        static let caption: CGFloat = 12
        static let small: CGFloat = 12
        static let body: CGFloat = 14
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let title: CGFloat = 28
        static let display: CGFloat = 40
        static let hero: CGFloat = 84
    }

    /// Semantic weights so call sites don't sprinkle `.semibold` / `.bold` literals.
    struct FontWeight {
        static let regular: Font.Weight = .regular
        static let medium: Font.Weight = .medium
        static let semibold: Font.Weight = .semibold
        static let bold: Font.Weight = .bold
    }

    // MARK: - Typography roles (preferred)

    /// Named text roles built on system text styles, so they scale with Dynamic Type and stay
    /// visually consistent across the app. Usage: `.font(Style.Typography.cardTitle)`.
    /// All roles use `.rounded` for a soft, friendly, calm feel that fits Dare's lowkey,
    /// low-pressure direction (a personal journal, not a loud engagement app).
    enum Typography {
        /// Big welcome / hero copy (e.g. onboarding).
        static var largeTitle: Font { .system(.largeTitle, design: .rounded).weight(.bold) }
        /// The main title of a screen (maps to the prevalent `.title2` usage).
        static var screenTitle: Font { .system(.title2, design: .rounded).weight(.bold) }
        /// A grouping/section header inside a screen (e.g. "Appearance" in Settings).
        static var sectionTitle: Font { .system(.title3, design: .rounded).weight(.semibold) }
        /// The title of a card, row, or list item.
        static var cardTitle: Font { .system(.headline, design: .rounded).weight(.semibold) }
        /// Primary running text — the workhorse body role.
        static var body: Font { .system(.subheadline, design: .rounded) }
        /// Body text that needs emphasis (names, key values).
        static var bodyStrong: Font { .system(.subheadline, design: .rounded).weight(.semibold) }
        /// Label inside buttons.
        static var button: Font { .system(.headline, design: .rounded).weight(.semibold) }
        /// Supporting/secondary text under a title.
        static var secondary: Font { .system(.footnote, design: .rounded) }
        /// Metadata, timestamps, counts.
        static var caption: Font { .system(.caption, design: .rounded) }
        /// Smallest supporting text.
        static var caption2: Font { .system(.caption2, design: .rounded) }
    }
}
