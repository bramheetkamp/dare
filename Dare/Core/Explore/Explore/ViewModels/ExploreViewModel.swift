//
//  ExploreViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 16/06/2025.
//

import Foundation
import FirebaseAuth

class ExploreViewModel: ObservableObject {
    @Published var categories: [ChallengeCategory] = []
    private let challengeService = ChallengeService()
    private let friendService = FriendService()
    
    init() {
        fetchCategories()
        fetchRecommendations()
    }

    func fetchCategories() {
        challengeService.fetchChallengeCategories { [weak self] fetched in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.categories = fetched
            }
        }
    }
    
    func fetchRecommendations() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        friendService.fetchRecommendedFriends(currentUserId: currentUserId) { users in
            print(users)
        }
    }
}
