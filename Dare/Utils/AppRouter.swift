//
//  AppRouter.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2025.
//

import SwiftUI

@MainActor
class AppRouter: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: AppDestination?
    @Published var presentedFullScreenCover: AppDestination?
    @Published var selectedTabIndex: Int = 0
    @Published var emojiPickerIndex: EmojiPickerIndex?

    struct EmojiPickerIndex: Identifiable {
        var id: Int
    }
    
    // Navigation stack management
    private var navigationHistory: [AppDestination] = []
    
    // MARK: - Navigation Methods
    
    func navigate(to destination: AppDestination) {
        navigationPath.append(destination)
        navigationHistory.append(destination)
    }
    
    func navigateBack() {
        guard !navigationPath.isEmpty else { return }
        
        // Remove from history but keep view models cached
        if !navigationHistory.isEmpty {
            navigationHistory.removeLast()
        }
        navigationPath.removeLast()
    }
    
    func popToRoot() {
        // Clear navigation but preserve view models for potential return
        navigationPath = NavigationPath()
        navigationHistory.removeAll()
    }
    
    // MARK: - Sheet Management
    
    func present(sheet destination: AppDestination) {
        presentedSheet = destination
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    func present(fullScreenCover destination: AppDestination) {
        presentedFullScreenCover = destination
    }
    
    func dismissFullScreenCover() {
        presentedFullScreenCover = nil
    }
    
    // MARK: - Deep Linking Support
    
    func handle(url: URL) {
        guard let destination = AppDestination.from(url: url) else { return }

        // Tab switching logic
        switch destination {
        case .home:
            popToRoot()
            selectedTabIndex = 0
            return
        case .explore:
            popToRoot()
            selectedTabIndex = 1
            return
        case .profile:
            popToRoot()
            selectedTabIndex = 2
            return
        default:
            popToRoot()
            navigate(to: destination)
        }
    }
    
    func createDeepLink(for destination: AppDestination) -> URL? {
        let baseURL = "yourapp://your-domain.com"
        
        switch destination {
        case .challengeDetail(let challengeId):
            return URL(string: "\(baseURL)/challenge?id=\(challengeId)")
        case .postDetail(let postId):
            return URL(string: "\(baseURL)/post?id=\(postId)")
        case .profile(let userId):
            return URL(string: "\(baseURL)/profile?id=\(userId)")
        default:
            return nil
        }
    }
}

