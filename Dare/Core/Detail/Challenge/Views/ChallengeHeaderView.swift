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
                .frame(height: 200 + safeAreaTopPadding())
                .cornerRadius(Style.CornerRadius.small, corners: [.bottomLeft, .bottomRight])
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.challenge?.challenge ?? "-")
                            .font(.title2).fontWeight(.black)
                            .foregroundColor(Color.white)
                            .lineLimit(2)
                        Text(viewModel.challenge?.caption ?? "-")
                            .font(.subheadline)
                            .foregroundColor(Color.white)
                            .lineLimit(2)
                    }
                }
                .padding(.top, safeAreaTopPadding())
            }
            .padding(.leading, 16)
            .padding(.bottom, 16)
        }
    }
    
    func safeAreaTopPadding() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
}

