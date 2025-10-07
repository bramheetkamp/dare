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

            Text("4 updates · \(challenge.caption) supporters")
                .font(.subheadline)
                .foregroundColor(Color("detailText"))
                .lineLimit(1)
                .truncationMode(.tail)
            
            InteractiveButton(
                action: {
                    guard let challengeId = challenge.id else { return }
                    router.navigate(to: .challengeDetail(challengeId: challengeId))
                },
                backgroundColor: .primaryButton.opacity(0.9),
                cornerRadius: Style.CornerRadius.small,
                padding: 10,
                scaleEffect: true
            ) {
                HStack {
                    Text("Add an update")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.white)
                    Spacer()
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.white)
                }
            }
        }
        .padding()
        .background(Color("cell"))
        .cornerRadius(Style.CornerRadius.small)
        .frame(maxWidth: UIScreen.main.bounds.width * 0.6)
    }
}
