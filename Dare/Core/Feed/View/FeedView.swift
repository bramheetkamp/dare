import SwiftUI

enum FeedFilter: String, CaseIterable {
    case all = "All"
    case friends = "Friends"
}

struct FeedView: View {

    // MARK: - Properties

    @EnvironmentObject private var postsStore: PostsStore
    @EnvironmentObject private var usersStore: UsersStore
    @EnvironmentObject private var challengesStore: ChallengesStore

    var body: some View {
        TodayView(
            postsStore: postsStore,
            usersStore: usersStore,
            challengesStore: challengesStore
        )
    }
}
