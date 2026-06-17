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
    
    @FocusState private var focusedField: Field?
    @State private var challenge = ""
    @State private var caption = ""
    @State private var selectedEmojis: [String?] = [nil, nil, nil]
    @State private var isPrivate: Bool = true

    @ObservedObject var viewModel = CreateChallengeViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    inputs
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 120 + (keyboard.isKeyboardVisible ? 0 : safeAreaBottomPadding()))
            }
            
            sendButton
        }
        .ignoresSafeArea(edges: .bottom)
        .withStandardPageStyle(title: "Create Challenge", extendView: false)
        .sheet(item: $router.emojiPickerIndex) { _ in
            sheetView
        }
    }
    
    // MARK: Views
    
    private var inputs: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderLabelView(text: "Tell more about it.", size: .title3)
            CustomTextField(
                placeholder: "Run ten marathons 🏃🏼‍♂️",
                limit: 30,
                value: $challenge,
                focus: $focusedField,
                focusField: .challenge
            )
            .focused($focusedField, equals: .challenge)
            .onSubmit {
                focusedField = .caption
            }
            
            CustomTextEditor(
                placeholder: "I wanna do every marathon in a different country!",
                value: $caption,
                focus: $focusedField,
                focusField: .caption
            )
            .focused($focusedField, equals: .caption)
            .onSubmit {
                createChallenge()
            }
            
            emojiSelectionWithDisplay
            
            HeaderLabelView(text: "Details.", size: .title3)
            InformationView(information: "Want give people the chance to add posts to your challenge or keep it to yourself?")
            CustomSwitch(
                title: isPrivate ? "Private Challenge" : "Public Challenge",
                isOn: $isPrivate
            )
        }
    }
    
    // MARK: Emoji
    
    private func shouldShowDeleteButton(for index: Int) -> Bool {
        let count = selectedEmojis.compactMap { $0 }.count
        guard count > 0 else { return false }
        return selectedEmojis[index] != nil
    }

    private func deleteEmoji(at index: Int) {
        guard index < selectedEmojis.count else { return }
        selectedEmojis[index] = nil
    }
    
    private var emojiSelectionWithDisplay: some View {
        HStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { index in
                EmojiBlock(
                    emoji: selectedEmojis[index],
                    showDeleteButton: shouldShowDeleteButton(for: index),
                    onDelete: {
                        deleteEmoji(at: index)
                    },
                    onTap: {
                        router.emojiPickerIndex = AppRouter.EmojiPickerIndex(id: index)
                    }
                )
                .frame(width: 80, height: 80)
            }
            
            EmojiDisplaySquare(emojis: selectedEmojis, size: 80)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var sendButton: some View {
        ZStack(alignment: .bottom) {
            let baseHeight: CGFloat = 52 + 32
            let backgroundHeight = baseHeight + (keyboard.isKeyboardVisible ? keyboard.keyboardHeight : safeAreaBottomPadding())
            
            Color(.cell)
                .cornerRadius(Style.CornerRadius.small, corners: [.topLeft, .topRight])
                .frame(height: backgroundHeight)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .bottom)
            
            InteractiveButton(
                action: createChallenge,
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
            .disabled(challenge.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, (keyboard.isKeyboardVisible ? keyboard.keyboardHeight : safeAreaBottomPadding()) + 16)
        }
    }
    
    private var sheetView: some View {
        EmojiPickerView(
            emojis: Emoji.emojis,
            selectedIndex: router.emojiPickerIndex?.id ?? 0,
            onSelect: { emoji in
                if let id = router.emojiPickerIndex?.id {
                    selectedEmojis[id] = emoji
                }
                router.emojiPickerIndex = nil
            },
            onCancel: {
                router.emojiPickerIndex = nil
            }
        )
        .presentationDetents([.fraction(0.5), .large])
        .interactiveDismissDisabled(false)
    }
    
    func createChallenge() {
        let nonNilEmojis = selectedEmojis.compactMap { $0 }
        viewModel.createChallenge(title: challenge, description: caption, emojis: nonNilEmojis) { challenge in
            router.popToRoot()
            
            guard let challengeId = challenge?.id else { return }
            router.navigate(to: .challengeDetail(challengeId: challengeId))
        }
    }
    
}
