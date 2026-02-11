//
//  CreatePostView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI
import Combine
import Kingfisher
import PhotosUI
import CoreTransferable
import _AVKit_SwiftUI

struct CreatePostView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var postsStore: PostsStore
    @EnvironmentObject private var authViewModel: AuthViewModel
    @ObservedObject private var keyboard = KeyboardResponder()
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: CreatePostViewModel
    
    @State private var challenge = ""
    @State private var title = ""
    @State private var caption = ""
    @State private var selectedImages: [UIImage] = []
    @State private var selectedVideoURLs: [URL] = []
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var player = AVPlayer(url: URL(string: "https://swiftanytime-content.s3.ap-south-1.amazonaws.com/SwiftUI-Beginner/Video-Player/iMacAdvertisement.mp4")!)
    
    @State private var location = ""
    @State private var challengeType = ""
    @State private var selectedDate = Date()
    @State private var selectedFilter: FeedFilter = .all
    
    @FocusState private var focusedField: Field?
    
    private let challengeId: String
    
    // MARK: - Init
    
    init(challengeId: String) {
        self.challengeId = challengeId
        _viewModel = StateObject(wrappedValue: CreatePostViewModel(challengeId: challengeId))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    infoSection
                    captionSection
                    extraInfoSection
                    submissionSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 120 + (keyboard.isKeyboardVisible ? 0 : safeAreaBottomPadding()))
            }
            
            sendButton
        }
        .ignoresSafeArea(edges: .bottom)
        .withStandardPageStyle(title: "Create Post", extendView: false)
    }
    
    // MARK: - View Components
    
    private var infoSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Update is part of challenge")
                    .font(.caption)
                    .opacity(0.8)
                Text(viewModel.challenge?.challenge ?? "-")
                    .lineLimit(1)
                    .font(.subheadline)
            }

            Spacer()
            
            if ((viewModel.challenge?.emojis) != nil) {
                EmojiDisplaySquare(emojis: (viewModel.challenge?.emojis)!, size: 50)
            }
        }
        .foregroundStyle(.headerText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.cell)
        .cornerRadius(Style.CornerRadius.small)
    }
    
    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderLabelView(text: "Tell more about it.", size: .title3)
            CustomTextField(
                placeholder: "Morning post",
                value: $title,
                focus: $focusedField,
                focusField: .title
            )
            .focused($focusedField, equals: .title)
            .onSubmit {
                focusedField = .caption
            }
            
            CustomTextEditor(
                placeholder: "What did you see? How was it?",
                value: $caption,
                focus: $focusedField,
                focusField: .caption
            )
            .focused($focusedField, equals: .caption)
            .onSubmit {
                focusedField = nil
            }
        }
    }
    
    private var extraInfoSection: some View {
        VStack(alignment: .leading) {
            HeaderLabelView(text: "Details", size: .title3)
            
            VStack(spacing: 16) {
                LocationSearchView(location: $location)
            }
        }
    }
    
    private var datePickerView: some View {
        ZStack {
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .labelsHidden()
            .padding(10)
            .background(Color.clear)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .center)
            .onTapGesture {
                focusedField = .date
            }
        }
        .background(Color.cell)
        .cornerRadius(Style.CornerRadius.small)
    }
    
    private var submissionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderLabelView(text: "Submission", size: .title3)
            MediaSelectionView(
                selectedImages: $selectedImages,
                selectedVideos: $selectedVideoURLs
            )
        }
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
                action: sendPost,
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
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, (keyboard.isKeyboardVisible ? keyboard.keyboardHeight : safeAreaBottomPadding()) + 16)
        }
    }
    
    // MARK: - Actions
    
    private func sendPost() {
        print("test \(selectedImages) \(selectedVideoURLs)")
        viewModel.createPost(
            title: title,
            caption: caption,
            images: selectedImages,
            videoUrls: selectedVideoURLs,
            location: location,
            type: challengeType,
            date: selectedDate
        ) { createdPost in
            guard let createdPost = createdPost else { return }
            postsStore.insertOrUpdate([createdPost])
            router.navigateBack()
        }
    }
    
    func safeAreaBottomPadding() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    
}
