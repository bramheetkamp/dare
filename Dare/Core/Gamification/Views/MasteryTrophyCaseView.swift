//
//  MasteryTrophyCaseView.swift
//  Dare
//
//  Gamification trophy case — a grid of all achievements, locked or unlocked.
//

import SwiftUI

struct MasteryTrophyCaseView: View {
    let points: Int
    let longestStreak: Int

    private var achievements: [Achievement] {
        AchievementCatalog.achievements(points: points, longestStreak: longestStreak)
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HeaderLabelView(text: "Trophies")
                Spacer()
                let unlocked = AchievementCatalog.unlockedCount(points: points, longestStreak: longestStreak)
                Text("\(unlocked) / \(AchievementCatalog.totalCount)")
                    .font(.subheadline)
                    .foregroundStyle(Color("detailText"))
                    .padding(.trailing, 16)
            }

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(achievements, id: \.id) { achievement in
                    AchievementBadgeView(achievement: achievement)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct AchievementBadgeView: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(achievement.isUnlocked
                          ? Color("primaryButton").opacity(0.15)
                          : Color("cell"))
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: achievement.icon)
                            .font(.title2)
                            .foregroundStyle(
                                achievement.isUnlocked
                                    ? Color("primaryButton")
                                    : Color("detailText").opacity(0.3)
                            )
                    }

                if !achievement.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(Color("detailText").opacity(0.5))
                        .offset(x: 4, y: -4)
                }
            }

            Text(achievement.title)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(
                    achievement.isUnlocked
                        ? Color("headerText")
                        : Color("detailText").opacity(0.4)
                )
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .opacity(achievement.isUnlocked ? 1.0 : 0.65)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            achievement.isUnlocked
                ? "\(achievement.title): \(achievement.description)"
                : "\(achievement.title): locked. \(achievement.description)"
        )
    }
}

#Preview {
    ScrollView {
        MasteryTrophyCaseView(points: 150, longestStreak: 8)
            .padding()
    }
}
