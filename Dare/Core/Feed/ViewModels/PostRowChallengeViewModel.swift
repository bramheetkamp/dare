//
//  PostRowChallengeViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 19/10/2025.
//

import Foundation

class PostRowChallengeViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private let challengeId: String
    private let challengesStore: ChallengesStore
    
    @Published var challenge: Challenge?
    private let challengeService = ChallengeService()

    // MARK: - Lifecycle
    
    init(challengeId: String, challengesStore: ChallengesStore) {
        self.challengeId = challengeId
        self.challengesStore = challengesStore
        loadChallenge()
    }
    
    // MARK: - Methods
    
    func loadChallenge() {
        if let cached = challengesStore.challenge(withId: challengeId) {
            self.challenge = cached
        } else {
            fetchChallenge()
        }
    }
    
    func fetchChallenge() {
        challengeService.fetchChallenge(challengeId: challengeId) { [weak self] fetchedChallenge in
            guard let self = self else { return }
            self.challenge = fetchedChallenge
            if let challenge = fetchedChallenge {
                self.challengesStore.insertOrUpdate([challenge])
            }
        }
    }
    
}


