//
//  FeedHeaderView.swift
//  Dare
//
//  Floating title shown over the feed. The streak/points live in the main toolbar
//  (StreakBadgeView), so this stays focused on the contextual title.
//

import SwiftUI

struct FeedHeaderView: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: title)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
            Spacer()
        }
        .frame(height: 44)
    }
}
