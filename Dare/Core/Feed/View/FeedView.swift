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
    @State private var currentIndex: Int? = 0

    var body: some View {
        FeedListView(
            postsStore: postsStore,
            usersStore: usersStore,
            challengesStore: challengesStore,
            selectedFilter: $selectedFilter,
            currentIndex: $currentIndex
        )
    }
}
