//
//  ChallengeRowView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/01/2025.
//

import SwiftUI

struct ChallengeRowView: View {
    let challenge: Challenge
    @EnvironmentObject private var router: AppRouter
    @State private var navigateToChallenge = false
    
    init(challenge: Challenge) {
        self.challenge = challenge
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.challenge)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                let caption = challenge.caption.isEmpty ? "" : " · \(challenge.caption)"
                Text("4 updates\(caption)")
                    .font(.subheadline)
                    .foregroundColor(Color("detailText"))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            InteractiveButtonStack(
                action: {
                    guard let challengeId = challenge.id else { return }
                    router.navigate(to: .challengeDetail(challengeId: challengeId))
                },
                cornerRadius: Style.CornerRadius.big,
                backgroundColor: Color("primaryButton").opacity(0.1)
            ) {
                HStack(spacing: 6) {
                    Text("Show more")
                        .font(.footnote)
                        .fontWeight(.medium)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                }
                .foregroundColor(Color("primaryButton"))
            }
        }
        .padding()
        .background(Color("cell"))
        .cornerRadius(Style.CornerRadius.small)
    }
}
