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
    @State private var selectedImage: UIImage? = nil
    @State private var selectedVideoURL: URL? = nil
    @State private var selectedItem: [PhotosPickerItem] = []
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
        InformationView(information: "Only your followers can see your challenge.")
    }
    
    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ChallengeEditorView(
                placeholder: "Amazing experience!",
                value: $title
            )
            
            HeaderLabelView(text: "How was it?", size: .title3)
            ChallengeEditorView(
                placeholder: "My dad and my friends were cheering me on along the way!",
                value: $caption
            )
        }
    }
    
    private var extraInfoSection: some View {
        VStack(alignment: .leading) {
            HeaderLabelView(text: "Extra Information", size: .title3)
            
            VStack(spacing: 16) {
                LocationSearchView(location: $location)
                
                datePickerView
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
            
            Text("Add a photo or video")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            PhotosPicker(
                selection: $selectedItem,
                maxSelectionCount: 1,
                matching: .any(of: [.images, .videos])
            ) {
                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.white)
                    Text("Choose media")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(Style.CornerRadius.small)
            }
            .onChange(of: selectedItem) {
                handleMediaSelection()
            }
            
            mediaPreviewView()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cell)
        .cornerRadius(Style.CornerRadius.small)
    }
    
    private var sendButton: some View {
        ZStack(alignment: .bottom) {
            let baseHeight: CGFloat = 60 + 32
            let backgroundHeight = baseHeight + (keyboard.isKeyboardVisible ? keyboard.keyboardHeight : safeAreaBottomPadding())
            
            Color("secondaryButton")
                .cornerRadius(Style.CornerRadius.small, corners: [.topLeft, .topRight])
                .frame(height: backgroundHeight)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .bottom)
            
            InteractiveButton(
                action: sendPost,
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
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, (keyboard.isKeyboardVisible ? keyboard.keyboardHeight : safeAreaBottomPadding()) + 16)
        }
    }
    
    // MARK: - Media Handling
    
    private func handleMediaSelection() {
        Task {
            guard let item = selectedItem.first else { return }
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                selectedVideoURL = nil
                player = AVPlayer()
            } else {
                item.loadTransferable(type: Movie.self) { result in
                    switch result {
                    case .success(let movie):
                        if let movie = movie {
                            selectedVideoURL = movie.url
                            selectedImage = nil
                            player = AVPlayer(url: movie.url)
                        }
                    case .failure(let error):
                        print("Failed to load video: \(error)")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func mediaPreviewView() -> some View {
        if let image = selectedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(
                    maxWidth: UIScreen.main.bounds.width * 0.9,
                    maxHeight: UIScreen.main.bounds.height * 0.5
                )
        } else if let url = selectedVideoURL,
                  let thumbnailImage = viewModel.generateThumbnail(url: url) {
            let aspectRatio = thumbnailImage.size.width / thumbnailImage.size.height
            VideoPlayer(player: player)
                .aspectRatio(aspectRatio, contentMode: .fit)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
        } else {
            EmptyView()
        }
    }
    
    // MARK: - Actions
    
    private func sendPost() {
        viewModel.createPost(
            title: title,
            caption: caption,
            image: selectedImage,
            videoUrl: selectedVideoURL,
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
