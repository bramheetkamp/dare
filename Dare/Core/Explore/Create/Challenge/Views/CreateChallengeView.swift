//
//  CreateChallengeView.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import SwiftUI

struct CreateChallengeView: View {
    
    @EnvironmentObject private var router: AppRouter
    @State private var challenge = ""
    @State private var caption = ""
    @FocusState private var focusedField: Field?
    
    @ObservedObject var viewModel = CreateChallengeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ZStack(alignment: .bottomLeading) {
                    Color("primaryButton")
                        .frame(height: 140 + safeAreaTopPadding())
                        .cornerRadius(Style.CornerRadius.small, corners: [.bottomLeft, .bottomRight])
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("New Challenge")
                                    .font(.title2).fontWeight(.black)
                                    .foregroundColor(Color.white)
                            }
                        }
                        .padding(.top, safeAreaTopPadding())
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                
                // Challenge Section
                VStack(spacing: 16) {
                    HeaderLabelView(text: "What would you like to do?", size: .title3)
                        .padding(.top, 20)
                    
                    ChallengeInputView(
                        placeholder: "Become a baker",
                        value: $challenge,
                        focus: $focusedField,
                        focusField: .challenge
                    )
                    .focused($focusedField, equals: .challenge)
                    .onSubmit {
                        focusedField = .caption
                    }
                    
                    ChallengeInputView(
                        placeholder: "Description",
                        value: $caption,
                        focus: $focusedField,
                        focusField: .caption
                    )
                    .focused($focusedField, equals: .caption)
                    .onSubmit {
                        createChallenge()
                    }

                    AnimatedButton(
                        action: createChallenge,
                        label: "Start your journey!",
                        backgroundColor: Color("primaryButton"),
                        foregroundColor: .white,
                        cornerRadius: Style.CornerRadius.small
                    )
                    .disabled(challenge.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.top, 40)
                }
                .padding(.horizontal, 16)

                Spacer()
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    func createChallenge() {
        viewModel.createChallenge(title: challenge, description: caption) { challenge in
            router.dismissSheet()
            
            guard let challengeId = challenge?.id else { return }
            router.navigate(to: .challengeDetail(challengeId: challengeId))
        }
    }
    
    func safeAreaTopPadding() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
    
}
