//
//  FeedChallengeListView.swift
//  Dare
//
//  Created by Bram Heetkamp on 06/07/2025.
//

import SwiftUI

struct FeedChallengeListView: View {
    var challenges: [Challenge]
    var onChallengeAppear: (Challenge) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(challenges, id: \.id) { challenge in
                    FeedChallengeRowView(challenge: challenge)
                        .onAppear {
                            onChallengeAppear(challenge)
                        }
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
        }
    }
}


