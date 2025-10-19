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
                VStack(alignment: .center, spacing: 8) {
                    Text(viewModel.challenge?.challenge ?? "")
                        .font(.title2).fontWeight(.black)
                        .foregroundColor(Color.white)
                    Text(viewModel.challenge?.caption ?? "")
                        .font(.title3).fontWeight(.black)
                        .foregroundColor(Color.white)
                }
                .padding(.top, safeAreaTopPadding())
                
                InteractiveButtonStack(
                    action: {
                        handleCopyChallenge()
                    },
                    cornerRadius: Style.CornerRadius.big,
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
        print("Copy")
    }
    
    func safeAreaTopPadding() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
}
