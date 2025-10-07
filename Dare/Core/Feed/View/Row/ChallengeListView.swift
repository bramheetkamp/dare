//
//  ChallengeListView.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import SwiftUI

struct ChallengeListView: View {
    var challenges: [Challenge]
    var onChallengeAppear: (Challenge) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 16) {
                ForEach(challenges, id: \.id) { challenge in
                    ChallengeRowView(challenge: challenge)
                        .onAppear {
                            onChallengeAppear(challenge)
                        }
                }
            }
        }
    }
}


