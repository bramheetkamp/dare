//
//  TestFeed.swift
//  Dare
//
//  Created by Bram Heetkamp on 11/02/2026.
//

import SwiftUI

struct TestFeed: View {

    // MARK: - Data

    private let closeFriendsItems: [FeedItem] = [
        .init(section: .closeFriends, title: "Close friends", subtitle: "Challenge from Sam", background: .blue),
        .init(section: .closeFriends, title: "Close friends", subtitle: "New dare from Lisa", background: .purple),
        .init(section: .closeFriends, title: "Close friends", subtitle: "24h challenge", background: .indigo)
    ]

    private let forYouItems: [FeedItem] = [
        .init(section: .forYou, title: "For you", subtitle: "Trending: " + "🔥", background: .orange),
        .init(section: .forYou, title: "For you", subtitle: "Random challenge", background: .green),
        .init(section: .forYou, title: "For you", subtitle: "Discover new groups", background: .pink),
        .init(section: .forYou, title: "For you", subtitle: "Daily inspiration", background: .teal)
    ]
    
    private let introBlocks: [FeedIntroItem] = [
        .init(title: "Tip 1", color: .red),
        .init(title: "Tip 2", color: .green),
        .init(title: "Tip 3", color: .blue),
        .init(title: "Tip 4", color: .orange)
    ]

    private var allItems: [FeedItem] {
        closeFriendsItems + forYouItems
    }

    // MARK: - State

    @State private var currentIndex: Int? = 0

    // MARK: - UI

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {

                // Fullscreen vertical paging (iOS 17+)
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        // Intro horizontal page first
                        FeedIntroPage(blocks: introBlocks)
                            .containerRelativeFrame(.vertical)
                            .id(0)

                        // Other vertical pages
                        ForEach(Array(allItems.enumerated()), id: \.element.id) { index, item in
                            FeedPage(item: item, bottomInset: geo.safeAreaInsets.bottom)
                                .containerRelativeFrame(.vertical)
                                .id(index + 1) // offset by 1 due to intro page
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollTargetLayout()
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $currentIndex)
                .ignoresSafeArea()

                // Fixed header (always below the notch)
                HeaderView(title: currentHeaderTitle)
                    .padding(.top, geo.safeAreaInsets.top + 10)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(.black)
            .ignoresSafeArea()
        }
    }
    
    var greetingMessage: String {
      let hour = Calendar.current.component(.hour, from: Date())
      if hour < 12 { return "Good morning" }
      if hour < 18 { return "Good afternoon" }
      return "Good evening"
    }

    private var currentHeaderTitle: String {
        if currentIndex == 0 { return greetingMessage}
        return "Submissions"
    }
}

#Preview {
    TestFeed()
}
