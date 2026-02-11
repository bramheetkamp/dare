//
//  MediaSelectionView.swift
//  Dare
//
//  Created by Bram Heetkamp on 23/10/2025.
//

import SwiftUI
import PhotosUI

struct MediaSelectionView: View {
    
    @Binding var selectedImages: [UIImage]
    @Binding var selectedVideos: [URL]
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if selectedImages.isEmpty && selectedVideos.isEmpty {
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 3,
                    matching: .any(of: [.images, .videos])
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle")
                        Text("Add photos/videos")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.primaryButton)
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.width / 3)
                    .background(.primaryButton.opacity(0.1))
                    .cornerRadius(Style.CornerRadius.small)
                }
                .onChange(of: selectedItems) { _, newItems in
                    handleMediaSelection(newItems)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedImages, id: \.self) { image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                                    .clipped()
                                    .cornerRadius(8)
                                
                                Button(action: {
                                    if let index = selectedImages.firstIndex(of: image) {
                                        selectedImages.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.cell)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .padding(6)
                            }
                        }
                        ForEach(selectedVideos, id: \.self) { url in
                            ZStack(alignment: .topTrailing) {
                                VideoThumbnailView(videoURL: url)
                                    .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                                    .cornerRadius(8)
                                
                                Button(action: {
                                    if let index = selectedVideos.firstIndex(of: url) {
                                        selectedVideos.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.cell)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .padding(6)
                            }
                        }
                        
                        PhotosPicker(
                            selection: $selectedItems,
                            maxSelectionCount: 3,
                            matching: .any(of: [.images, .videos])
                        ) {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle")
                                Text("Add photos/videos")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.primaryButton)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 3)
                            .background(.primaryButton.opacity(0.1))
                            .cornerRadius(Style.CornerRadius.small)
                        }
                        .onChange(of: selectedItems) { _, newItems in
                            handleMediaSelection(newItems)
                        }
                    }
                }
                .frame(height: UIScreen.main.bounds.width / 3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.cell)
        .cornerRadius(Style.CornerRadius.small)
    }
    
    private func handleMediaSelection(_ newItems: [PhotosPickerItem]) {
        for item in newItems {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data?):
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            selectedImages.append(image)
                        }
                    } else {
                        item.loadTransferable(type: URL.self) { videoResult in
                            switch videoResult {
                            case .success(let url?):
                                DispatchQueue.main.async {
                                    selectedVideos.append(url)
                                }
                            default:
                                break
                            }
                        }
                    }
                case .success(nil):
                    item.loadTransferable(type: URL.self) { videoResult in
                        switch videoResult {
                        case .success(let url?):
                            DispatchQueue.main.async {
                                selectedVideos.append(url)
                            }
                        default:
                            break
                        }
                    }
                case .failure(let error):
                    print("Failed to load media: \(error.localizedDescription)")
                }
            }
        }
        selectedItems = []
    }
}

struct VideoThumbnailView: View {
    let videoURL: URL
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "video.fill")
                .resizable()
                .scaledToFit()
                .padding(20)
                .foregroundColor(.white)
        }
    }
}

