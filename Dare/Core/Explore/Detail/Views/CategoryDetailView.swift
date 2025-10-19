//
//  CategoryDetailView.swift
//  Dare
//
//  Created by Bram Heetkamp on 16/06/2025.
//

import SwiftUI
import Kingfisher
import FirebaseAuth

struct CategoryDetailView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: CategoryDetailViewModel
    @State private var isFirstLoad = true
    
    private let categoryId: String
    
    // MARK: - Initialization
    
    init(categoryId: String) {
        self.categoryId = categoryId
        _viewModel = StateObject(wrappedValue: CategoryDetailViewModel(categoryId: categoryId))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    CategoryHeaderView(viewModel: viewModel)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        sectionHeader("Challenges")
                        
                        if viewModel.isLoading && viewModel.challenges.isEmpty {
                            LoadingIndicatorView()
                        } else if viewModel.challenges.isEmpty {
                            EmptyArrayMessageView(message: "No challenges yet. Come back soon!")
                        } else {
                            ChallengeListView(
                                challenges: viewModel.challenges,
                                onChallengeAppear: loadMoreChallengesIfNeeded
                            )
                        }
                        
                        if viewModel.isLoading && !viewModel.challenges.isEmpty {
                            LoadingIndicatorView()
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 80)
                    .padding(.horizontal, 16)
                }
            }
            .refreshable { refreshChallenges() }
            .onAppear(perform: loadInitialData)
        }
        .withStandardPageStyle()
    }
    
    // MARK: - Private Helpers
    
    private func sectionHeader(_ text: String) -> some View {
        HeaderLabelView(text: text)
    }
    
    private func loadMoreChallengesIfNeeded(for challenge: Challenge) {
        guard challenge.id == viewModel.challenges.last?.id,
              viewModel.hasMoreChallenges,
              !viewModel.isLoading,
              !viewModel.challenges.isEmpty else { return }
        viewModel.fetchChallenges()
    }
    
    private func refreshChallenges() {
        withAnimation {
            viewModel.resetPagination()
            viewModel.fetchChallenges()
        }
    }
    
    private func loadInitialData() {
        if isFirstLoad {
            viewModel.fetchChallenges()
            isFirstLoad = false
        } else {
            if viewModel.challenges.isEmpty {
                viewModel.fetchChallenges()
            }
        }
    }
}
