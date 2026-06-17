//
//  ExploreViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 16/06/2025.
//

import Foundation

class ExploreViewModel: ObservableObject {
    @Published var categories: [ChallengeCategory] = []
    private let challengeService = ChallengeService()

    init() {
        fetchCategories()
    }

    func fetchCategories() {
        challengeService.fetchChallengeCategories { [weak self] fetched in
            DispatchQueue.main.async {
                self?.categories = fetched
            }
        }
    }
}
