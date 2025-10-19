//
//  CreateChallengeView.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import SwiftUI

struct CreateChallengeView: View {
    
    @EnvironmentObject private var router: AppRouter
    @ObservedObject private var keyboard = KeyboardResponder()
    
    @State private var challenge = ""
    @State private var caption = ""
    @FocusState private var focusedField: Field?
    
    @ObservedObject var viewModel = CreateChallengeViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ChallengeInputView(
                        placeholder: "Run ten marathons 🏃🏼‍♂️",
                        value: $challenge,
                        focus: $focusedField,
                        focusField: .challenge
                    )
                    .focused($focusedField, equals: .challenge)
                    .onSubmit {
                        focusedField = .caption
                    }
                    .padding(.top, 16)
                    
                    ChallengeInputView(
                        placeholder: "I wanna do every marathon in a different country!",
                        value: $caption,
                        focus: $focusedField,
                        focusField: .caption
                    )
                    .focused($focusedField, equals: .caption)
                    .onSubmit {
                        createChallenge()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 120 + (keyboard.isKeyboardVisible ? 0 : safeAreaBottomPadding()))
            }
            
            ZStack(alignment: .bottom) {
                let baseHeight: CGFloat = 60 + 32
                let backgroundHeight = baseHeight + (keyboard.isKeyboardVisible ? keyboard.keyboardHeight : safeAreaBottomPadding())
                
                Color("secondaryButton")
                    .cornerRadius(Style.CornerRadius.small, corners: [.topLeft, .topRight])
                    .frame(height: backgroundHeight)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .bottom)
                
                InteractiveButton(
                    action: createChallenge,
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
                .disabled(challenge.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, (keyboard.isKeyboardVisible ? keyboard.keyboardHeight : safeAreaBottomPadding()) + 16)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .withStandardPageStyle(title: "Create Challenge", extendView: false)
        
    }
    
    func createChallenge() {
        viewModel.createChallenge(title: challenge, description: caption) { challenge in
            router.dismissSheet()
            
            guard let challengeId = challenge?.id else { return }
            router.navigate(to: .challengeDetail(challengeId: challengeId))
        }
    }
    
    func safeAreaBottomPadding() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    
}
