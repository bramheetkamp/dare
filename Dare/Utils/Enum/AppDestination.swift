//
//  AppDestination.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2025.
//

import SwiftUI

enum AppDestination: Hashable, Identifiable, Codable {
    case challengeDetail(challengeId: String)
    case postDetail(postId: String)
    case comments(postId: String)
    case challengeCategory(categoryId: String)
    case profile(userId: String)
    case createPost(challengeId: String)
    case createChallenge
    case home
    case explore
    case searchPeople
    case registration
    case profileSettings(userId: String)

    var id: String {
        switch self {
        case .challengeDetail(let id):
            return "challengeDetail_\(id)"
        case .postDetail(let id):
            return "postDetail_\(id)"
        case .comments(let id):
            return "comments_\(id)"
        case .challengeCategory(let id):
            return "challengeCategory_\(id)"
        case .profile(let id):
            return "profile_\(id)"
        case .createPost(let id):
            return "createPost_\(id)"
        case .createChallenge:
            return "createChallenge"
        case .home:
            return "home"
        case .explore:
            return "explore"
        case .searchPeople:
            return "searchPeople"
        case .registration:
            return "registration"
        case .profileSettings(let id):
            return "profileSettings_\(id)"
        }
    }
    
    // Deep linking support
    //
    // Accepts the custom scheme `dare://<route>?id=<id>` (route = URL host), and also tolerates
    // a path-style route (`dare://open/<route>?id=<id>`) and future https Universal Links
    // (`https://<domain>/<route>?id=<id>`). The route is matched against `mappings` below.
    static func from(url: URL) -> AppDestination? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }

        let trimmedPath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let host = components.host ?? ""

        let route: String
        switch components.scheme {
        case "dare":
            // For dare://challenge?id=1 the route lives in the host; fall back to the path.
            route = host.isEmpty ? trimmedPath : (mappings[host] != nil ? host : trimmedPath)
        case "https":
            route = trimmedPath
        default:
            return nil
        }

        let queryItems = components.queryItems ?? []

        if let (queryKey, constructor) = mappings[route] {
            if let queryKey = queryKey {
                if let value = queryItems.first(where: { $0.name == queryKey })?.value, !value.isEmpty {
                    return constructor(value)
                }
            } else {
                return constructor("")
            }
        }
        return nil
    }

    /// Route → (optional required query key, destination builder).
    private static let mappings: [String: (String?, (String) -> AppDestination)] = [
        "challenge": ("id", { .challengeDetail(challengeId: $0) }),
        "post": ("id", { .postDetail(postId: $0) }),
        "comments": ("id", { .comments(postId: $0) }),
        "category": ("id", { .challengeCategory(categoryId: $0) }),
        "profile": ("id", { .profile(userId: $0) }),
        "profileSettings": ("id", { .profileSettings(userId: $0) }),
        "createPost": ("id", { .createPost(challengeId: $0) }),
        "createChallenge": (nil, { _ in .createChallenge }),
        "home": (nil, { _ in .home }),
        "explore": (nil, { _ in .explore }),
        "searchPeople": (nil, { _ in .searchPeople }),
        "registration": (nil, { _ in .registration })
    ]
}

// Test from a booted simulator, e.g.:
//   xcrun simctl openurl booted "dare://challenge?id=<challengeId>"
//   xcrun simctl openurl booted "dare://home"
