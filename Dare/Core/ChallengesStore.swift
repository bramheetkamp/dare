//
//  ChallengesStore.swift
//  Dare
//
//  Created by Bram Heetkamp on 19/10/2025.
//

import Foundation

final class ChallengesStore: ObservableObject {
    
    @Published private(set) var challenges: [Challenge] = []
    
    private let challengeService = ChallengeService()
    
    func insertOrUpdate(_ newChallenges: [Challenge]) {
        for challenge in newChallenges {
            if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
                challenges[index] = challenge
            } else {
                challenges.append(challenge)
            }
        }
    }
    
    func challenge(withId id: String) -> Challenge? {
        challenges.first(where: { $0.id == id })
    }
}

