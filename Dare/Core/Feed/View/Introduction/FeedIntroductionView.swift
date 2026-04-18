//
//  FeedIntroductionView.swift
//  Dare
//
//  Created by Bram Heetkamp on 12/02/2026.
//

import SwiftUI

struct FeedIntroductionView: View {
    var challenges: [Challenge]
    var onChallengeAppear: (Challenge) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(challenges, id: \.id) { challenge in
                        FeedChallengeRowView(challenge: challenge)
                            .onAppear {
                                onChallengeAppear(challenge)
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            }

            Spacer()
        }
        .background(
            LinearGradient(colors: [.purple, .black], startPoint: .top, endPoint: .bottom)
        )
        .ignoresSafeArea()
    }
}
