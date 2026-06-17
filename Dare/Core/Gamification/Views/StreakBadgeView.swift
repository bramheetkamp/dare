//
//  StreakBadgeView.swift
//  Dare
//
//  Compact flame + points indicator shown in the main toolbar to reinforce daily streaks.
//

import SwiftUI

struct StreakBadgeView: View {
    let streak: Int
    let points: Int

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(streak > 0 ? .orange : .gray)
                Text("\(streak)")
                    .foregroundColor(.primary)
            }

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(Color("dareGold"))
                Text("\(points)")
                    .foregroundColor(.primary)
            }
        }
        .font(.subheadline.weight(.semibold))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(streak) day streak, \(points) points")
    }
}

/// Slim progress bar toward the next level — drop into profile or a stats sheet.
struct LevelProgressView: View {
    let points: Int

    private var progress: (level: Int, into: Int, span: Int) {
        GamificationLevel.progress(for: points)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Level \(progress.level)")
                    .font(.subheadline.weight(.bold))
                Spacer()
                Text("\(progress.into)/\(progress.span)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            ProgressView(value: GamificationLevel.fractionIntoLevel(for: points))
                .tint(Color("primaryButton"))
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        StreakBadgeView(streak: 7, points: 340)
        LevelProgressView(points: 340)
            .padding(.horizontal)
    }
}
