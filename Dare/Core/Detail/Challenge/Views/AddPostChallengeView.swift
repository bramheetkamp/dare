//
//  AddPostChallengeView.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import SwiftUI

struct AddPostChallengeView: View {
    
    @EnvironmentObject private var router: AppRouter
    
    private let challengeId: String
    
    init(challengeId: String) {
        self.challengeId = challengeId
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            let baseHeight: CGFloat = 52 + 32
            let backgroundHeight = baseHeight + safeAreaBottomPadding()
            
            Color(.cell)
                .cornerRadius(Style.CornerRadius.small, corners: [.topLeft, .topRight])
                .frame(height: backgroundHeight)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .bottom)
            
            InteractiveButton(
                action: {
                    router.navigate(to: .createPost(challengeId: challengeId))
                },
                backgroundColor: .primaryButton.opacity(0.1),
                cornerRadius: Style.CornerRadius.small,
                padding: 16,
                scaleEffect: true,
                height: 52,
            ) {
                HStack {
                    Text("Create")
                        .font(.system(size: Style.FontSize.medium, weight: .semibold))
                    Spacer()
                    Image(systemName: "plus")
                        .font(.system(size: Style.FontSize.medium, weight: .bold))
                }
                .foregroundColor(.primaryButton)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, (safeAreaBottomPadding() + 16))
        }
    }
    
    
}

