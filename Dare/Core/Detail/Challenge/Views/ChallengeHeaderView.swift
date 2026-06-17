//
//  ChallengeHeaderView.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import SwiftUI
import Kingfisher

struct ChallengeHeaderView: View {
    
    @EnvironmentObject private var router: AppRouter
    @ObservedObject var viewModel: ChallengeDetailViewModel
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color("primaryButton")
                .frame(height: 260 + safeAreaTopPadding())
                .cornerRadius(Style.CornerRadius.small, corners: [.bottomLeft, .bottomRight])
            
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    if let emojis = viewModel.challenge?.emojis {
                        EmojiDisplaySquare(
                            emojis: emojis,
                            size: 50
                        )
                    }
                    Text(viewModel.challenge?.challenge ?? "")
                        .font(.title2).fontWeight(.black)
                        .foregroundColor(Color.white)
                        .lineLimit(2)
                }
                .padding(.top, safeAreaTopPadding())
                
                InteractiveButtonStack(
                    action: {
                        handleCopyChallenge()
                    },
                    cornerRadius: Style.CornerRadius.small,
                    backgroundColor: Color("secondaryButton")
                ) {
                    HStack {
                        Text(viewModel.actionHeaderButtonTitle)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    
    private func handleCopyChallenge() {
        router.navigate(to: .createChallenge)
    }
    
}
