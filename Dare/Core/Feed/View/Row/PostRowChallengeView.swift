//
//  PostRowChallengeView.swift
//  Dare
//
//  Created by Bram Heetkamp on 14/06/2025.
//

import SwiftUI

struct PostRowChallengeView: View {
    
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var challengesStore: ChallengesStore
    
    @StateObject private var viewModel: PostRowChallengeViewModel
    
    @State private var navigateToChallenge = false
    
    var challengeId: String
    var challenge: Challenge? {
        challengesStore.challenge(withId: challengeId)
    }
    
    init(challengeId: String, challengesStore: ChallengesStore) {
        self.challengeId = challengeId
        _viewModel = StateObject(wrappedValue: PostRowChallengeViewModel(
            challengeId: challengeId,
            challengesStore: challengesStore
        ))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 2) {
                if let emojis = viewModel.challenge?.emojis {
                    EmojiDisplaySquare(
                        emojis: emojis,
                        size: 30
                    )
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Update is part of challenge")
                        .font(.caption)
                        .foregroundColor(Color("detailText"))
                    Text(challenge?.challenge ?? "-")
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundColor(Color("headerText"))
                }
                
                Spacer()
                
                InteractiveButtonStack(
                    action: {
                        router.navigate(to: .challengeDetail(challengeId: challengeId))
                    },
                    cornerRadius: Style.CornerRadius.small,
                    backgroundColor: .primaryButton.opacity(0.1)
                ) {
                    HStack(spacing: 4) {
                        Text("See more")
                            .font(.footnote)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundColor(.primaryButton)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                }
            }
            .padding(16)
            .background(Color("background").opacity(0.5))
            .cornerRadius(Style.CornerRadius.small)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
