//
//  DareApp.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/2024.
//

import SwiftUI
import FirebaseCore

@main
struct DareApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var router = AppRouter()
    @StateObject private var postsStore = PostsStore()
    @StateObject private var usersStore = UsersStore()
    @StateObject private var challengesStore = ChallengesStore()
    @StateObject private var playerManager = PlayerManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(router)
                .environmentObject(postsStore)
                .environmentObject(usersStore)
                .environmentObject(challengesStore)
                .environmentObject(playerManager)
                .onOpenURL { url in
                    router.handle(url: url)
                }
        }
    }
}
