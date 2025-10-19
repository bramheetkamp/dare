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
        VStack(alignment: .leading, spacing: 8) {
            Text(challenge.challenge)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)

            Text("\(challenge.caption)")
                .font(.subheadline)
                .foregroundColor(Color("detailText"))
                .lineLimit(1)
                .truncationMode(.tail)
            
            InteractiveButton(
                action: {
                    guard let challengeId = challenge.id else { return }
                    router.navigate(to: .challengeDetail(challengeId: challengeId))
                },
                backgroundColor: .primaryButton.opacity(0.1),
                cornerRadius: Style.CornerRadius.small,
                scaleEffect: true
            ) {
                HStack {
                    Text("Add an update")
                        .font(.system(size: Style.FontSize.medium, weight: .semibold))
                    Spacer()
                    Image(systemName: "plus")
                        .font(.system(size: Style.FontSize.medium, weight: .bold))
                }
                .foregroundColor(.primaryButton)
            }
        }
        .padding()
        .background(Color("cell"))
        .cornerRadius(Style.CornerRadius.small)
        .frame(maxWidth: UIScreen.main.bounds.width * 0.6)
    }
}
