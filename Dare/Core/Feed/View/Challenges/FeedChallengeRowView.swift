//
//  FeedChallengeRowView.swift
//  Dare
//
//  Created by Bram Heetkamp on 07/07/2025.
//

import SwiftUI

struct FeedChallengeRowView: View {
    var challenge: Challenge
    @EnvironmentObject private var router: AppRouter
    @State private var navigateToChallenge = false
    
    init(challenge: Challenge) {
        self.challenge = challenge
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(.red)
            .frame(width: 200, height: 300)
            .overlay(alignment: .bottomLeading) {
                VStack {
                    Text(challenge.challenge)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 4)
                    InteractiveButton(
                        action: {
                            guard let challengeId = challenge.id else { return }
                            router.navigate(to: .challengeDetail(challengeId: challengeId))
                        },
                        backgroundColor: .primary,
                        cornerRadius: Style.CornerRadius.small,
                        scaleEffect: true
                    ) {
                        HStack {
                            Text("Check in")
                                .font(.system(size: Style.FontSize.medium, weight: .semibold))
                            Spacer()
                            Image(systemName: "plus")
                                .font(.system(size: Style.FontSize.medium, weight: .bold))
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
    }
