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
            let baseHeight: CGFloat = 60 + 32
            let backgroundHeight = baseHeight + safeAreaBottomPadding()
            
            Color("secondaryButton")
                .cornerRadius(Style.CornerRadius.small, corners: [.topLeft, .topRight])
                .frame(height: backgroundHeight)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .bottom)
            
            InteractiveButton(
                action: {
                    router.navigate(to: .createPost(challengeId: challengeId))
                },
                backgroundColor: .primaryButton,
                cornerRadius: Style.CornerRadius.small,
                padding: 16,
                scaleEffect: true,
                height: 60,
            ) {
                HStack {
                    Text("Create")
                        .font(.system(size: Style.FontSize.medium, weight: .semibold))
                        .foregroundColor(Color.white)
                    Spacer()
                    Image(systemName: "plus")
                        .font(.system(size: Style.FontSize.medium, weight: .bold))
                        .foregroundColor(Color.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, (safeAreaBottomPadding() + 16))
        }
    }
    
    func safeAreaBottomPadding() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    
}

