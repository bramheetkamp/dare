//
//  QuickPostView.swift
//  Dare
//
//  Photo-first, one-screen posting experience. Select a photo, write a short note, post.
//  Replaces the multi-section CreatePostView in the main create flow.
//

import SwiftUI
import PhotosUI

// Pure predicate — separated so it can be unit-tested without SwiftUI.
struct QuickPostValidator {
    static func canPost(note: String, hasImage: Bool) -> Bool {
        hasImage && !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct QuickPostView: View {

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var postsStore: PostsStore

    @StateObject private var viewModel: CreatePostViewModel

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var note: String = ""
    @State private var isUploading = false
    @FocusState private var noteFocused: Bool

    init(challengeId: String) {
        _viewModel = StateObject(wrappedValue: CreatePostViewModel(challengeId: challengeId))
    }

    private var canPost: Bool {
        QuickPostValidator.canPost(note: note, hasImage: selectedImage != nil)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    photoCard
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    noteField
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 100)
            }
        }
        .overlay(alignment: .bottom) { postButton }
        .withStandardPageStyle(title: "Quick Post", extendView: false)
        .onChange(of: selectedItem) { _, item in
            Task {
                guard let item else { return }
                guard let data = try? await item.loadTransferable(type: Data.self),
                      let img = UIImage(data: data) else { return }
                await MainActor.run {
                    selectedImage = img
                    noteFocused = true
                }
            }
        }
    }

    // MARK: - Subviews

    private var photoCard: some View {
        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            Color(.systemGray6)
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 44))
                                    .foregroundColor(Color("detailText"))
                                Text("Tap to add photo")
                                    .font(.subheadline)
                                    .foregroundColor(Color("detailText"))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.55)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                if selectedImage != nil {
                    Text("change")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.55))
                        .clipShape(Capsule())
                        .padding(12)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var noteField: some View {
        TextField("What's the vibe?", text: $note)
            .font(.title3.weight(.semibold))
            .foregroundColor(Color("headerText"))
            .focused($noteFocused)
            .submitLabel(.done)
            .onSubmit { noteFocused = false }
            .padding(14)
            .background(Color("cell"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var postButton: some View {
        Button(action: post) {
            ZStack {
                if isUploading {
                    ProgressView().tint(.white)
                } else {
                    Text("Post")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                canPost && !isUploading
                    ? Color("primaryButton")
                    : Color("primaryButton").opacity(0.35)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!canPost || isUploading)
        .padding(.horizontal, 16)
        .padding(.bottom, safeAreaBottomPadding() + 16)
        .background(Color("background"))
    }

    // MARK: - Actions

    private func post() {
        guard let image = selectedImage else { return }
        isUploading = true
        viewModel.createPost(
            title: note,
            caption: "",
            images: [image],
            videoUrls: [],
            location: nil,
            type: nil,
            date: nil
        ) { createdPost in
            isUploading = false
            guard let createdPost = createdPost else { return }
            postsStore.insertOrUpdate([createdPost])
            router.navigateBack()
        }
    }
}
