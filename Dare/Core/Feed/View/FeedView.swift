import SwiftUI
import FirebaseAuth

enum FeedFilter: String, CaseIterable {
    case all = "All"
    case friends = "Friends"
}

struct FeedView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var postsStore: PostsStore
    @State private var selectedFilter: FeedFilter = .all

    var body: some View {
        FeedListView(postsStore: postsStore, selectedFilter: $selectedFilter)
    }
}
