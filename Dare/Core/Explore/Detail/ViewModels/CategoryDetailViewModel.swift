//
//  CategoryDetailViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 16/06/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class CategoryDetailViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var challenges: [Challenge] = []
    @Published var isLoading = false
    @Published var hasMoreChallenges = true
    
    private let challengeService = ChallengeService()
    private var lastDocument: DocumentSnapshot? = nil
    private let pageSize = 5
    
    private let challengeCategoryId: String
    @Published var challengeCategory: ChallengeCategory?
    
    // MARK: - Initialization
    
    init(categoryId: String) {
        self.challengeCategoryId = categoryId
        fetchChallengeCategory()
    }
    
    // MARK: - Methods
    
    func fetchChallengeCategory() {
        challengeService.fetchChallengeCategory(challengeCategoryId: challengeCategoryId) { [weak self] category in
            guard let self = self else { return }
            self.challengeCategory = category
            self.fetchChallenges()
        }
    }
    
    func fetchChallenges() {
        guard let categoryId = challengeCategory?.id, !isLoading, hasMoreChallenges else { return }
        isLoading = true
        
        challengeService.fetchChallenges(categoryId: categoryId, limit: pageSize, lastDocument: lastDocument) { [weak self] newChallenges, lastDoc in
            guard let self = self else { return }
            if newChallenges.isEmpty {
                self.hasMoreChallenges = false
            } else {
                self.challenges.append(contentsOf: newChallenges)
            }
            self.lastDocument = lastDoc
            self.isLoading = false
        }
    }
    
    func resetPagination() {
        challenges.removeAll()
        lastDocument = nil
        hasMoreChallenges = true
    }
    
}
