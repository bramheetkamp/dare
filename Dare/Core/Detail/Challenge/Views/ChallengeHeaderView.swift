//
//  ChallengeHeaderView.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import SwiftUI
import Kingfisher

struct ChallengeHeaderView: View {

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
                
                if viewModel.isCurrentUserCreator {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.white.opacity(0.85))
                        Text("Your goal")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white.opacity(0.85))
                        if viewModel.participantCount > 0 {
                            Text("· \(viewModel.participantCount) joined")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.65))
                        }
                    }
                    .padding(.vertical, 8)
                } else {
                    InteractiveButtonStack(
                        action: viewModel.toggleJoin,
                        cornerRadius: Style.CornerRadius.small,
                        backgroundColor: viewModel.isCurrentUserJoined
                            ? Color.white.opacity(0.2)
                            : Color("secondaryButton")
                    ) {
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.isCurrentUserJoined
                                  ? "checkmark" : "person.badge.plus")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.white)
                            Text(viewModel.isCurrentUserJoined ? "Joined" : "Join Goal")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.white)
                            if viewModel.participantCount > 0 {
                                Text("· \(viewModel.participantCount)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    
}

