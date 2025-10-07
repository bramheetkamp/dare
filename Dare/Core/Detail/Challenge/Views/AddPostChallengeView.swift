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
        VStack {
            Spacer()
            InteractiveButton(
                action: {
                    router.navigate(to: .createPost(challengeId: challengeId))
                },
                backgroundColor: .secondaryButton,
                cornerRadius: Style.CornerRadius.small,
                padding: 16,
                scaleEffect: true
            ) {
                HStack {
                    Text("Add a new update")
                        .font(.system(size: Style.FontSize.medium, weight: .semibold))
                        .foregroundColor(Color.white)
                    Spacer()
                    Image(systemName: "plus")
                        .font(.system(size: Style.FontSize.medium, weight: .bold))
                        .foregroundColor(Color.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

