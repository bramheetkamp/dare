import SwiftUI
import FirebaseAuth

enum FeedFilter: String, CaseIterable {
    case all = "All"
    case friends = "Friends"
}

struct FeedView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var postsStore: PostsStore
    @EnvironmentObject private var usersStore: UsersStore
    @EnvironmentObject private var challengesStore: ChallengesStore
    @State private var selectedFilter: FeedFilter = .all

    var body: some View {
        FeedListView(
            postsStore: postsStore,
            usersStore: usersStore,
            challengesStore: challengesStore,
            selectedFilter: $selectedFilter
        )
    }
}
