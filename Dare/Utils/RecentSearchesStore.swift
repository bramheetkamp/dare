//
//  RecentSearchesStore.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import Foundation

/// Persists the ids of recently viewed people so the search screen can offer quick re-access.
/// Backed by `UserDefaults` (ids only — the user docs are re-fetched on display).
final class RecentSearchesStore: ObservableObject {

    private let key = "recentSearchedUserIds"
    private let maxItems = 12
    private let defaults: UserDefaults

    @Published private(set) var userIds: [String]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.userIds = defaults.stringArray(forKey: key) ?? []
    }

    /// Records a visited user id, moving it to the front and trimming to `maxItems`.
    func record(_ userId: String) {
        guard !userId.isEmpty else { return }
        var ids = userIds.filter { $0 != userId }
        ids.insert(userId, at: 0)
        userIds = Array(ids.prefix(maxItems))
        defaults.set(userIds, forKey: key)
    }

    func clear() {
        userIds = []
        defaults.removeObject(forKey: key)
    }
}
