//
//  CreatePostViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI

@MainActor
class CreatePostViewModel: ObservableObject {
    
    // MARK: - Properties
    
    let challengeId: String
    @Published var challenge: Challenge?
    @Published var didUploadPost = false
    
    private let challengeService = ChallengeService()
    private let postUploadService = PostUploadService()
    
    // MARK: - Initialization
    
    init(challengeId: String) {
        self.challengeId = challengeId
        fetchChallenge()
    }
    
    // MARK: - Methods
    
    func fetchChallenge() {
        challengeService.fetchChallenge(challengeId: challengeId) { [weak self] challenge in
            guard let self = self, let challenge = challenge else { return }
            self.challenge = challenge
        }
    }
    
    func createPost(
        title: String?,
        caption: String,
        images: [UIImage],
        videoUrls: [URL],
        location: String?,
        type: String?,
        date: Date?,
        completion: @escaping (PublicPost?) -> Void
    ) {
        guard let challengeId = challenge?.id else {
            completion(nil)
            return
        }

        var uploadedImageUrls: [String] = []
        var uploadedVideoUrls: [String] = []
        
        let group = DispatchGroup()

        // Upload images
        for image in images {
            group.enter()
            postUploadService.uploadSingleImage(image: image) { url in
                if let url = url {
                    uploadedImageUrls.append(url)
                }
                group.leave()
            }
        }
        
        // Upload videos
        for videoUrl in videoUrls {
            group.enter()
            postUploadService.uploadSingleVideo(videoUrl: videoUrl) { url in
                if let url = url {
                    uploadedVideoUrls.append(url)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.postUploadService.savePostWithMediaArrays(
                challengeId: challengeId,
                title: title,
                caption: caption,
                location: location,
                imageUrls: uploadedImageUrls,
                videoUrls: uploadedVideoUrls,
                date: date,
                completion: completion
            )
        }
    }
    
}
