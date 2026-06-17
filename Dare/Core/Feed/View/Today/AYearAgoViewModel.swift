//
//  AYearAgoViewModel.swift
//  Dare
//
//  Powers the "you, a year ago" resurfacing — the emotional core of Dare. It looks up your
//  own posts from a window around this date last year, so you can see how far you've come.
//

import Foundation
import FirebaseAuth

@MainActor
final class AYearAgoViewModel: ObservableObject {

    @Published private(set) var memories: [PublicPost] = []
    @Published private(set) var hasLoaded = false

    private let postFetchService = PostFetchService()

    /// How many days either side of "one year ago today" still counts as a memory.
    private let windowDays = 7

    func load() {
        guard !hasLoaded, let uid = Auth.auth().currentUser?.uid else { return }
        hasLoaded = true

        let calendar = Calendar.current
        let now = Date()
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now),
              let start = calendar.date(byAdding: .day, value: -windowDays, to: oneYearAgo),
              let end = calendar.date(byAdding: .day, value: windowDays, to: oneYearAgo) else { return }

        postFetchService.fetchPosts(uid: uid, from: start, to: end) { [weak self] posts in
            DispatchQueue.main.async {
                self?.memories = posts
            }
        }
    }
}
