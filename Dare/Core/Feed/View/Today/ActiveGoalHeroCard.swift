//
//  ActiveGoalHeroCard.swift
//  Dare
//
//  Ring 2 hero on the Today screen: your active journey + a one-tap "post an update"
//  call to action. If you have no journey yet, it nudges you to start one.
//

import SwiftUI

struct ActiveGoalHeroCard: View {
    let goal: Challenge?
    let onPost: () -> Void
    let onStart: () -> Void

    var body: some View {
        if let goal {
            activeCard(goal)
        } else {
            startCard
        }
    }

    private func activeCard(_ goal: Challenge) -> some View {
        let now = Date()
        let fraction = ChallengeSeasonLogic.progressFraction(
            start: goal.endDate != nil ? goal.startDate : nil,
            end: goal.endDate,
            at: now
        )
        let daysLabel = ChallengeSeasonLogic.statusLabel(end: goal.endDate, from: now)

        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                EmojiDisplaySquare(emojis: (goal.emojis ?? []).map { $0 as String? }, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("YOUR JOURNEY")
                        .font(.caption2.weight(.bold))
                        .tracking(1.5)
                        .foregroundColor(.white.opacity(0.75))
                    Text(goal.challenge)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                if let label = daysLabel {
                    Text(label)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }
            }

            if !goal.caption.isEmpty {
                Text(goal.caption)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
            }

            if let fraction {
                SeasonProgressBar(fraction: fraction)
            }

            primaryButton(title: "Post an update", icon: "camera.fill", action: onPost)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color("primaryButton"), Color("dareBlue")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var startCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "sparkles")
                .font(.title)
                .foregroundColor(.white)
            Text("Start your first journey")
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
            Text("Pick something you want to get good at — baking, lifting, drawing — and post quick updates as you go.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))

            primaryButton(title: "Create a goal", icon: "plus", action: onStart)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color("dareGreen"), Color("primaryButton")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func primaryButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
                Image(systemName: "arrow.right")
            }
            .font(.headline)
            .foregroundColor(Color("primaryButton"))
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Season progress bar

/// A thin horizontal bar showing how far through the season the goal is.
private struct SeasonProgressBar: View {
    let fraction: Double   // 0…1

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.25))
                    .frame(height: 4)
                Capsule()
                    .fill(.white)
                    .frame(width: max(4, geo.size.width * fraction), height: 4)
            }
        }
        .frame(height: 4)
    }
}
