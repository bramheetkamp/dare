//
//  TodayView.swift
//  Dare
//
//  Ring 1 + Ring 2 home: a calm, finite grid of what your (small) circle is up to today,
//  topped by your active-journey hero card. No infinite scroll, no like counts — a lowkey
//  window into what drives the people around you.
//

import SwiftUI

struct TodayView: View {

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var usersStore: UsersStore
    @StateObject private var viewModel: FeedViewModel
    @StateObject private var memories = AYearAgoViewModel()

    @State private var isFirstLoad = true

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    init(postsStore: PostsStore, usersStore: UsersStore, challengesStore: ChallengesStore) {
        _viewModel = StateObject(wrappedValue: FeedViewModel(
            postsStore: postsStore,
            usersStore: usersStore,
            challengesStore: challengesStore
        ))
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                ActiveGoalHeroCard(
                    goal: viewModel.challenges.first,
                    onPost: postUpdate,
                    onStart: { router.navigate(to: .createChallenge) }
                )

                AYearAgoCard(memories: memories.memories) { memory in
                    guard let id = memory.id else { return }
                    router.navigate(to: .locketPost(postId: id))
                }

                circleSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 100)
        }
        .background(Color("background"))
        .refreshable { refresh() }
        .onAppear(perform: loadInitial)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(greeting)
                .font(.largeTitle.weight(.bold))
                .foregroundColor(Color("headerText"))
            Text("What your circle is up to")
                .font(.subheadline)
                .foregroundColor(Color("detailText"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var circleSection: some View {
        let posts = viewModel.posts(forFilter: .all)

        HStack {
            Text("Your circle today")
                .font(Style.Typography.sectionTitle)
                .foregroundColor(Color("headerText"))
            Spacer()
        }

        if posts.isEmpty {
            emptyCircle
        } else {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(posts) { post in
                    CircleTileView(post: post, usersStore: usersStore)
                        .onTapGesture {
                            guard let id = post.id else { return }
                            router.navigate(to: .locketPost(postId: id))
                        }
                        .onAppear { loadMoreIfNeeded(for: post) }
                }
            }
        }
    }

    private var emptyCircle: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.2")
                .font(.largeTitle)
                .foregroundColor(Color("detailText"))
            Text("It's quiet here")
                .font(.headline)
                .foregroundColor(Color("headerText"))
            Text("Follow a few friends to see what drives them — or post the first update yourself.")
                .font(.subheadline)
                .foregroundColor(Color("detailText"))
                .multilineTextAlignment(.center)
            Button("Find people") { router.navigate(to: .searchPeople) }
                .font(.headline)
                .foregroundColor(Color("primaryButton"))
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Actions

    private func postUpdate() {
        guard let goalId = viewModel.challenges.first?.id else {
            router.navigate(to: .createChallenge)
            return
        }
        router.navigate(to: .createPost(challengeId: goalId))
    }

    private func loadInitial() {
        guard isFirstLoad else { return }
        isFirstLoad = false
        viewModel.fetchChallenges()
        memories.load()
    }

    private func loadMoreIfNeeded(for post: PublicPost) {
        let posts = viewModel.posts(forFilter: .all)
        guard post.id == posts.last?.id,
              viewModel.hasMorePosts,
              !viewModel.isLoadingPosts else { return }
        viewModel.fetchPosts()
    }

    private func refresh() {
        viewModel.resetPagination()
        viewModel.fetchPosts()
        viewModel.fetchChallenges()
    }
}
