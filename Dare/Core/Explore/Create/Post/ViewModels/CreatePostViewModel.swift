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
        caption: String,
        image: UIImage?,
        videoUrl: URL?,
        location: String?,
        type: String?,
        date: Date?,
        completion: @escaping (PublicPost?) -> Void
    ) {
        guard let challengeId = challenge?.id else {
            completion(nil)
            return
        }
        postUploadService.uploadPost(
            challengeId: challengeId,
            caption: caption,
            location: location,
            image: image,
            videoUrl: videoUrl,
            challengeType: type,
            date: date
        ) { [weak self] post in
            guard let self = self else { return }
            if let post = post {
                self.didUploadPost = true
                print("DEBUG: Successfully uploaded post")
                completion(post)
            } else {
                print("DEBUG: Failed to upload post")
                completion(nil)
            }
        }
    }
    
    func generateThumbnail(url: URL) -> UIImage? {
        return postUploadService.generateThumbnail(from: url)
    }
    
}
