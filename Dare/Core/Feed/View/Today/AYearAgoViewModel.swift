//
//  AYearAgoViewModel.swift
//  Dare
//
//  Powers the "you, a year ago" resurfacing — the emotional core of Dare. It looks up your
//  own posts from a window around this date last year, so you can see how far you've come.
//  Once loaded, it also schedules a weekly push notification for the best memory found.
//

import Foundation
import FirebaseAuth

@MainActor
final class AYearAgoViewModel: ObservableObject {

    @Published private(set) var memories: [PublicPost] = []
    @Published private(set) var hasLoaded = false

    private let postFetchService = PostFetchService()
    private let notificationService = NotificationService()

    func load() {
        guard !hasLoaded, let uid = Auth.auth().currentUser?.uid else { return }
        hasLoaded = true

        let calendar = Calendar.current
        let now = Date()
        let windowDays = YearAgoNotificationLogic.windowDays
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now),
              let start = calendar.date(byAdding: .day, value: -windowDays, to: oneYearAgo),
              let end = calendar.date(byAdding: .day, value: windowDays, to: oneYearAgo) else { return }

        postFetchService.fetchPosts(uid: uid, from: start, to: end) { [weak self] posts in
            DispatchQueue.main.async {
                guard let self else { return }
                self.memories = posts
                self.scheduleReminderIfNeeded(from: posts)
            }
        }
    }

    // MARK: - Private

    private func scheduleReminderIfNeeded(from posts: [PublicPost]) {
        let pairs = YearAgoNotificationLogic.pairs(from: posts)
        guard let bestId = YearAgoNotificationLogic.bestPostId(from: pairs) else {
            notificationService.cancelYearAgoReminder()
            return
        }
        let note = posts.first(where: { $0.id == bestId }).flatMap { p in
            if let t = p.title, !t.isEmpty { return t }
            if let c = p.caption, !c.isEmpty { return c }
            return nil
        }
        notificationService.scheduleYearAgoReminder(postId: bestId, note: note)
    }
}
