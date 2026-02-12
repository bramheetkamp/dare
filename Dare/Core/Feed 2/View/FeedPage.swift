//
//  FeedPage.swift
//  Dare
//
//  Created by Bram Heetkamp on 12/02/2026.
//

import SwiftUI

struct FeedPage: View {
    let item: FeedItem
    let bottomInset: CGFloat // <- pass from parent

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            // Fullscreen background
            LinearGradient(
                colors: [item.background.opacity(0.9), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Page content respecting safe areas
            VStack(alignment: .leading, spacing: 10) {
                Spacer()

                Text(item.subtitle)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)

                Text("Swipe up")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20 + bottomInset) // <- ensure above TabView
        }
        .overlay(
            VStack(spacing: 18) {
                Spacer()

                Image(systemName: "heart.fill")
                    .font(.title2)

                Image(systemName: "bubble.right.fill")
                    .font(.title2)

                Image(systemName: "paperplane.fill")
                    .font(.title2)

                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.trailing, 16),
            alignment: .trailing
        )
    }
}
