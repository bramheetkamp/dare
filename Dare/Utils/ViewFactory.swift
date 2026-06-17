//
//  ViewFactory.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2025.
//

import SwiftUI

struct ViewFactory {
    
    @MainActor
    static func view(for destination: AppDestination, router: AppRouter) -> AnyView {
        switch destination {
        case .challengeDetail(let challengeId):
            return AnyView(
                ChallengeDetailView(challengeId: challengeId)
                    .environmentObject(router)
            )
        case .postDetail(let postId):
            return AnyView(
                PostView(postId: postId)
                    .environmentObject(router)
            )
        case .comments(let postId):
            return AnyView(
                CommentsView(postId: postId)
                    .environmentObject(router)
            )
        case .challengeCategory(let categoryId):
            return AnyView(
                CategoryDetailView(categoryId: categoryId)
                    .environmentObject(router)
            )
        case .profile(let userId):
            return AnyView(
                ProfileView(userId: userId)
                    .environmentObject(router)
            )
        case .createPost(let challengeId):
            return AnyView(
                CreatePostView(challengeId: challengeId)
                    .environmentObject(router)
            )
            
        case .createChallenge:
            return AnyView(
                CreateChallengeView()
                    .environmentObject(router)
            )
        case .home:
            return AnyView(
                FeedView()
                    .environmentObject(router)
            )
        case .explore:
            return AnyView(
                ExploreView()
                    .environmentObject(router)
            )
        case .searchPeople:
            return AnyView(
                SearchUsersView()
                    .environmentObject(router)
            )
        case .searchGroups:
            return AnyView(
                GroupSearchView()
                    .environmentObject(router)
            )
        case .createGroup:
            return AnyView(
                CreateGroupView()
                    .environmentObject(router)
            )
        case .groupDetail(let groupId):
            return AnyView(
                GroupDetailView(groupId: groupId)
                    .environmentObject(router)
            )
        case .contactsFriends:
            return AnyView(
                ContactsFriendsView()
                    .environmentObject(router)
            )
        case .registration:
            return AnyView(
                RegistrationView()
                    .environmentObject(router)
            )
        case .profileSettings(let userId):
            return AnyView(
                ProfileSettingsView(userId: userId)
                    .environmentObject(router)
            )
        }
    }
    
}

